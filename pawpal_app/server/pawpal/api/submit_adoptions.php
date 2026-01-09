<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // 1. Ambil data POST daripada Flutter
    $user_id = $_POST['user_id'] ?? '';
    $pet_id = $_POST['pet_id'] ?? ''; // Diambil dari widget.pet.petId
    $donation_type = $_POST['donation_type'] ?? '';
    $description = $_POST['description'] ?? '';
    
    // 2. Validasi: Pastikan field penting tidak kosong
    if (empty($user_id) || empty($pet_id) || empty($donation_type) || empty($description)) {
        echo json_encode([
            "status" => "failed", 
            "message" => "Sila pastikan semua maklumat diisi dengan lengkap."
        ]);
        exit;
    }

    // 3. Simpan maklumat ke dalam tbl_donations
    // Status ditetapkan secara default kepada 'pending'
    $stmt = $conn->prepare("INSERT INTO tbl_donations (user_id, pet_id, donation_type, description, status, created_at) VALUES (?, ?, ?, ?, 'pending', NOW())");
    
    // "iiss" bermaksud integer (user_id), integer (pet_id), string (type), string (desc)
    $stmt->bind_param("iiss", $user_id, $pet_id, $donation_type, $description);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Sumbangan anda telah berjaya dihantar! Kami akan mengemaskini status sumbangan anda dalam masa terdekat."
        ]);
    } else {
        echo json_encode([
            "status" => "failed",
            "message" => "Ralat pangkalan data: " . $stmt->error
        ]);
    }

    $stmt->close();
    $conn->close();

} else {
    echo json_encode([
        "status" => "failed", 
        "message" => "Kaedah permintaan tidak sah."
    ]);
}
?>