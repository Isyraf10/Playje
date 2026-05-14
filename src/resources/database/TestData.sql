
INSERT INTO users (user_id, username, email, password, role) VALUES
('S75516', 'Nurbatrisyia', 's75516@ocean.umt.edu.my', '123', 'student'),
('S75327', 'Sarah', 's75327@ocean.umt.edu.my', '123', 'student'),
('S75717', 'Isyraf', 's75717@ocean.umt.edu.my', '123', 'ajk'),
('ADV001', 'Dr. Noraida', 'advisor@ocean.umt.edu.my', '123', 'advisor');

INSERT INTO student_profile (student_id, matric_no, faculty, is_member) VALUES
('S75516', 'UMT12345', 'Faculty of Computer Science and Mathematics', 1),
('S75327', 'UMT12346', 'Faculty of Computer Science and Mathematics', 1);

INSERT INTO ajk_profile (ajk_id, position) VALUES
('S75717', 'President');

INSERT INTO advisor_profile (advisor_id, staff_id, faculty) VALUES
('ADV001', 'STAFF002', 'Faculty of Computer Science and Mathematics');

INSERT INTO pricing (pricing_id, station_type, base_price_per_hour, happy_hour) VALUES
('P001', 'PS5', 5.00, 0.80),
('P002', 'Car Simulator', 8.00, 0.80);

INSERT INTO gaming_station (station_id, pricing_id, station_name, status, specifications) VALUES
('PS001', 'P001', 'PS5 Station 1', 'available', 'Sony PS5 + 2 DualSense'),
('PS002', 'P001', 'PS5 Station 2', 'occupied', 'Sony PS5 + 2 DualSense'),
('CS001', 'P002', 'Logitech G29 Simulator 1', 'available', 'Logitech G29 Wheel + 1 Playseat');