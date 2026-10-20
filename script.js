// booking_script.js - Booking Form JavaScript

// Function to calculate and update price
function updatePrice() {
    const select = document.getElementById('room_type');
    const option = select.options[select.selectedIndex];
    const price = parseFloat(option.getAttribute('data-price')) || 0;

    const startDate = new Date(document.getElementById('stay_start').value);
    const endDate = new Date(document.getElementById('stay_end').value);

    if (startDate && endDate && endDate > startDate) {
        const nights = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
        const total = price * nights;

        document.getElementById('price_per_night').textContent = price.toFixed(2) + ' EGP';
        document.getElementById('num_nights').textContent = nights;
        document.getElementById('total_price').textContent = total.toFixed(2) + ' EGP';
    }
}

// Update checkout minimum date when checkin changes
document.getElementById('stay_start').addEventListener('change', function () {
    const checkin = new Date(this.value);
    const checkout = document.getElementById('stay_end');

    checkin.setDate(checkin.getDate() + 1);
    checkout.min = checkin.toISOString().split('T')[0];

    // If checkout is before new minimum, update it
    if (checkout.value && new Date(checkout.value) <= new Date(this.value)) {
        checkout.value = checkout.min;
    }

    updatePrice();
});

// Update price when checkout date changes
document.getElementById('stay_end').addEventListener('change', function () {
    updatePrice();
});

// Validate dates on form submission
document.querySelector('form').addEventListener('submit', function (e) {
    const startDate = new Date(document.getElementById('stay_start').value);
    const endDate = new Date(document.getElementById('stay_end').value);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (startDate < today) {
        e.preventDefault();
        alert('Check-in date must be today or in the future!');
        return false;
    }

    if (endDate <= startDate) {
        e.preventDefault();
        alert('Check-out date must be after check-in date!');
        return false;
    }

    // Check guest capacity
    const select = document.getElementById('room_type');
    const option = select.options[select.selectedIndex];
    const capacity = parseInt(option.getAttribute('data-capacity'));
    const guests = parseInt(document.querySelector('input[name="number_guests"]').value);

    if (guests > capacity) {
        e.preventDefault();
        alert('The selected room can accommodate maximum ' + capacity + ' guest(s)!');
        return false;
    }
});