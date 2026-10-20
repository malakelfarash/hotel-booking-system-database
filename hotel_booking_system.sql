-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Dec 05, 2025 at 04:36 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotel_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `booking`
--

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL,
  `guest_id` int(11) NOT NULL,
  `staff_id` int(11) DEFAULT NULL,
  `number_guests` int(11) NOT NULL CHECK (`number_guests` > 0),
  `stay_start` date NOT NULL,
  `stay_end` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking`
--

INSERT INTO `booking` (`booking_id`, `guest_id`, `staff_id`, `number_guests`, `stay_start`, `stay_end`) VALUES
(1, 1, 2, 1, '2025-05-10', '2025-05-12'),
(2, 2, 1, 2, '2025-06-01', '2025-06-05'),
(3, 3, 3, 3, '2025-07-15', '2025-07-20'),
(4, 4, 1, 1, '2025-02-01', '2025-02-03'),
(21, 6, 1, 3, '2025-12-08', '2025-12-10'),
(22, 7, 1, 2, '2025-12-22', '2025-12-25'),
(23, 6, 1, 1, '2025-12-06', '2025-12-08');

-- --------------------------------------------------------

--
-- Table structure for table `booking_room`
--

CREATE TABLE `booking_room` (
  `booking_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking_room`
--

INSERT INTO `booking_room` (`booking_id`, `room_id`) VALUES
(1, 101),
(2, 202),
(3, 303),
(4, 104),
(21, 406),
(22, 205),
(23, 203);

--
-- Triggers `booking_room`
--
DELIMITER $$
CREATE TRIGGER `prevent_double_booking` BEFORE INSERT ON `booking_room` FOR EACH ROW BEGIN
    IF (SELECT is_booked FROM room WHERE room_id = NEW.room_id) = 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot book this room: it is already booked.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `set_room_booked` AFTER INSERT ON `booking_room` FOR EACH ROW BEGIN
    UPDATE room
    SET is_booked = 1
    WHERE room_id = NEW.room_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `set_room_unbooked` AFTER DELETE ON `booking_room` FOR EACH ROW BEGIN
    UPDATE room
    SET is_booked = 0
    WHERE room_id = OLD.room_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `guest`
--

CREATE TABLE `guest` (
  `guest_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `guest`
--

INSERT INTO `guest` (`guest_id`, `first_name`, `last_name`, `gender`, `email`, `phone_number`) VALUES
(1, 'Mona', 'Hassan', 'Female', 'monahassan@gmail.com', '01012345678'),
(2, 'Ahmed', 'Khaled', 'Male', 'ahmedkhaled@gmail.com', '01087654321'),
(3, 'Sara', 'Ali', 'Female', 'saraali@gmail.com', NULL),
(4, 'Ahmed', 'Khaled', 'Male', 'ahmed.khaled@gmail.com', '01123456789'),
(6, 'Nada', 'Abdelkader', 'Female', 'nadaabdelkader42@gmail.com', '01010101010'),
(7, 'Ali', 'Elsawy', 'Male', '0bcfccc80b@webxio.pro', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `payment_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `payment_amount` decimal(10,2) NOT NULL,
  `method_name` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`payment_id`, `booking_id`, `payment_amount`, `method_name`) VALUES
(1, 1, 500.00, 'Credit Card'),
(2, 2, 900.00, 'Cash'),
(3, 3, 1800.00, 'Debit Card'),
(4, 21, 3600.00, 'Credit Card'),
(5, 22, 2700.00, 'Bank Transfer'),
(6, 23, 1800.00, 'Cash');

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `room_id` int(11) NOT NULL,
  `floor_number` int(11) DEFAULT NULL,
  `is_booked` tinyint(1) NOT NULL,
  `type_id` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `room`
--

INSERT INTO `room` (`room_id`, `floor_number`, `is_booked`, `type_id`) VALUES
(101, 1, 1, 'SL'),
(104, 1, 1, 'SL'),
(202, 2, 1, 'DL'),
(203, 2, 1, 'DL'),
(204, 2, 0, 'DL'),
(205, 2, 1, 'DL'),
(303, 3, 1, 'SU'),
(304, 3, 0, 'SU'),
(305, 3, 0, 'SU'),
(401, 4, 0, 'FL'),
(406, 4, 1, 'FL');

-- --------------------------------------------------------

--
-- Table structure for table `room_type`
--

CREATE TABLE `room_type` (
  `type_id` varchar(5) NOT NULL,
  `type_name` varchar(15) NOT NULL,
  `price` decimal(10,2) NOT NULL CHECK (`price` > 0),
  `capacity` int(11) NOT NULL CHECK (`capacity` >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `room_type`
--

INSERT INTO `room_type` (`type_id`, `type_name`, `price`, `capacity`) VALUES
('DL', 'Double', 900.00, 2),
('FL', 'Family', 1800.00, 5),
('SL', 'Single', 500.00, 1),
('SU', 'Suite', 1500.00, 4);

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `staff_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `salary` decimal(10,2) NOT NULL CHECK (`salary` > 0),
  `email` varchar(50) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`staff_id`, `first_name`, `last_name`, `gender`, `salary`, `email`, `phone_number`, `manager_id`) VALUES
(1, 'Omar', 'Samir', 'Male', 12000.00, 'omarsamir@gmail.com', '01110986601', NULL),
(2, 'Laila', 'Mostafa', 'Female', 15000.00, 'lailamostafa@gmail.com', '01278652208', 1),
(3, 'Hadi', 'Youssef', 'Male', 8000.00, 'hadiyoussef@gmail.com', '01098763570', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `guest_id` (`guest_id`),
  ADD KEY `staff_id` (`staff_id`);

--
-- Indexes for table `booking_room`
--
ALTER TABLE `booking_room`
  ADD PRIMARY KEY (`booking_id`,`room_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `guest`
--
ALTER TABLE `guest`
  ADD PRIMARY KEY (`guest_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`payment_id`),
  ADD UNIQUE KEY `booking_id` (`booking_id`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `type_id` (`type_id`);

--
-- Indexes for table `room_type`
--
ALTER TABLE `room_type`
  ADD PRIMARY KEY (`type_id`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`staff_id`),
  ADD KEY `manager_id` (`manager_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `guest`
--
ALTER TABLE `guest`
  MODIFY `guest_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `staff_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`guest_id`) REFERENCES `guest` (`guest_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `booking_room`
--
ALTER TABLE `booking_room`
  ADD CONSTRAINT `booking_room_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `booking_room_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `booking` (`booking_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `room_type` (`type_id`);

--
-- Constraints for table `staff`
--
ALTER TABLE `staff`
  ADD CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `staff` (`staff_id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
