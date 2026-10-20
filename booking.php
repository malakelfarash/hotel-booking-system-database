<?php
session_start();

// Database connection
$host = 'localhost:3307';
$user = 'root';
$pass = '';
$db = 'hotel_system';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Process form submission
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $conn->begin_transaction();

    try {
        // Get form data
        $first_name = mysqli_real_escape_string($conn, trim($_POST['first_name']));
        $last_name = mysqli_real_escape_string($conn, trim($_POST['last_name']));
        $gender = mysqli_real_escape_string($conn, $_POST['gender']);
        $email = mysqli_real_escape_string($conn, trim($_POST['email']));
        $phone = !empty($_POST['phone']) ? mysqli_real_escape_string($conn, trim($_POST['phone'])) : NULL;
        $room_type = mysqli_real_escape_string($conn, $_POST['room_type']);
        $number_guests = intval($_POST['number_guests']);
        $stay_start = $_POST['stay_start'];
        $stay_end = $_POST['stay_end'];
        $payment_method = mysqli_real_escape_string($conn, $_POST['payment_method']);

        // Check if guest exists
        $check_guest = $conn->query("SELECT guest_id FROM guest WHERE email = '$email'");

        if ($check_guest->num_rows > 0) {
            $guest_id = $check_guest->fetch_assoc()['guest_id'];
        } else {
            // Insert new guest
            $conn->query("INSERT INTO guest (first_name, last_name, gender, email, phone_number) 
                         VALUES ('$first_name', '$last_name', '$gender', '$email', " . ($phone ? "'$phone'" : "NULL") . ")");
            $guest_id = $conn->insert_id;
        }

        // Find available room
        $find_room = $conn->query("SELECT room_id FROM room WHERE type_id = '$room_type' AND is_booked = 0 LIMIT 1");

        if ($find_room->num_rows == 0) {
            throw new Exception('No rooms available for this type!');
        }

        $room_id = $find_room->fetch_assoc()['room_id'];

        // Get staff (if any)
        $staff_result = $conn->query("SELECT staff_id FROM staff LIMIT 1");
        $staff_id = $staff_result->num_rows > 0 ? $staff_result->fetch_assoc()['staff_id'] : NULL;

        // Insert booking
        $conn->query("INSERT INTO booking (guest_id, staff_id, number_guests, stay_start, stay_end) 
                     VALUES ($guest_id, " . ($staff_id ? $staff_id : "NULL") . ", $number_guests, '$stay_start', '$stay_end')");
        $booking_id = $conn->insert_id;

        // Link room to booking (triggers will set is_booked automatically)
        $conn->query("INSERT INTO booking_room (booking_id, room_id) VALUES ($booking_id, $room_id)");

        // Calculate payment
        $price_query = $conn->query("SELECT price FROM room_type WHERE type_id = '$room_type'");
        $price = $price_query->fetch_assoc()['price'];
        $nights = (strtotime($stay_end) - strtotime($stay_start)) / (60 * 60 * 24);
        $total = $price * $nights;

        // Insert payment
        $conn->query("INSERT INTO payment (booking_id, payment_amount, method_name) 
                     VALUES ($booking_id, $total, '$payment_method')");

        $conn->commit();

        $_SESSION['success'] = "Booking confirmed! Your booking ID is: #$booking_id";
        $_SESSION['booking_id'] = $booking_id;
        header('Location: booking.php');
        exit();
    } catch (Exception $e) {
        $conn->rollback();
        $_SESSION['error'] = "Error: " . $e->getMessage();
    }
}

// Get room types
$room_types = $conn->query("SELECT * FROM room_type ORDER BY price ASC");
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotel Booking</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <div class="container">
        <h1>Hotel Room Booking</h1>

        <?php if (isset($_SESSION['success'])): ?>
            <div class="alert alert-success">
                ✅ <?php echo $_SESSION['success'];
                    unset($_SESSION['success']); ?>
            </div>
        <?php endif; ?>

        <?php if (isset($_SESSION['error'])): ?>
            <div class="alert alert-error">
                ❌ <?php echo $_SESSION['error'];
                    unset($_SESSION['error']); ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="">
            <h2>Guest Information</h2>

            <div class="form-row">
                <div class="form-group">
                    <label>First Name *</label>
                    <input type="text" name="first_name" required>
                </div>

                <div class="form-group">
                    <label>Last Name *</label>
                    <input type="text" name="last_name" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Gender *</label>
                    <select name="gender" required>
                        <option value="">Select...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email" required>
                </div>
            </div>

            <div class="form-group form-group-full">
                <label>Phone Number</label>
                <input type="tel" name="phone" placeholder="01012345678">
            </div>

            <h2>Booking Details</h2>

            <div class="form-row">
                <div class="form-group">
                    <label>Room Type *</label>
                    <select name="room_type" id="room_type" required onchange="updatePrice()">
                        <option value="">Select room type...</option>
                        <?php while ($room = $room_types->fetch_assoc()): ?>
                            <option value="<?php echo $room['type_id']; ?>"
                                data-price="<?php echo $room['price']; ?>"
                                data-capacity="<?php echo $room['capacity']; ?>">
                                <?php echo $room['type_name']; ?> - <?php echo $room['price']; ?> EGP/night (<?php echo $room['capacity']; ?> guests)
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label>Number of Guests *</label>
                    <input type="number" name="number_guests" min="1" value="1" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label>Check-in Date *</label>
                    <input type="date" name="stay_start" id="stay_start"
                        min="<?php echo date('Y-d-m'); ?>" required onchange="updatePrice()">
                </div>

                <div class="form-group">
                    <label>Check-out Date *</label>
                    <input type="date" name="stay_end" id="stay_end"
                        min="<?php echo date('Y-d-m', strtotime('+1 day')); ?>" required onchange="updatePrice()">
                </div>
            </div>

            <div class="form-group form-group-full">
                <label>Payment Method *</label>
                <select name="payment_method" required>
                    <option value="">Select payment method...</option>
                    <option value="Credit Card">Credit Card</option>
                    <option value="Debit Card">Debit Card</option>
                    <option value="Cash">Cash</option>
                    <option value="Bank Transfer">Bank Transfer</option>
                </select>
            </div>

            <div class="price-info">
                <h3>Price Summary</h3>
                <div class="price-row">
                    <span>Price per night:</span>
                    <span id="price_per_night">-</span>
                </div>
                <div class="price-row">
                    <span>Number of nights:</span>
                    <span id="num_nights">-</span>
                </div>
                <div class="price-row total">
                    <span>Total Amount:</span>
                    <span id="total_price">-</span>
                </div>
            </div>

            <button type="submit">Book Now</button>
        </form>
    </div>

    <script src="script.js"></script>
</body>

</html>

<?php $conn->close(); ?>