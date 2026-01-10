<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

$input = file_get_contents("php://input");
$data = json_decode($input, true);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Ambil data berdasarkan key yang dihantar oleh Flutter body: {}
    $adopter_id = $_POST['adopter_id'] ?? ($data['adopter_id'] ?? '');
    $pet_id     = $_POST['pet_id'] ?? ($data['pet_id'] ?? '');
    $owner_id   = $_POST['owner_id'] ?? ($data['owner_id'] ?? '');
    $message    = $_POST['message'] ?? ($data['message'] ?? '');

    // Validasi: owner_id TIDAK BOLEH 0 atau kosong
    // Validasi: Beritahu data mana yang kosong
    if (empty($adopter_id) || empty($pet_id) || empty($owner_id) || empty($message)) {
        echo json_encode([
            "status" => "failed", 
            "message" => "Data tidak lengkap: " . 
                         (empty($adopter_id) ? "adopter_id " : "") .
                         (empty($pet_id) ? "pet_id " : "") .
                         (empty($owner_id) ? "owner_id " : "") .
                         (empty($message) ? "message " : "") . "kosong."
        ]);
        exit;
    }

    try {
        // Nama table: tbl_adoptions (berdasarkan ralat constraint anda)
        $sql = "INSERT INTO tbl_adoptions (pet_id, adopter_id, owner_id, message, status, created_at) 
                VALUES (?, ?, ?, ?, 'pending', NOW())";
        
        $stmt = $conn->prepare($sql);
        $stmt->bind_param("iiis", $pet_id, $adopter_id, $owner_id, $message);

        if ($stmt->execute()) {
            echo json_encode([
                "status" => "success",
                "message" => "Permohonan adopt berjaya dihantar!"
            ]);
        } else {
            echo json_encode([
                "status" => "failed",
                "message" => "Ralat SQL: " . $stmt->error 
            ]);
        }
        $stmt->close();
    } catch (Exception $e) {
        echo json_encode([
            "status" => "failed",
            "message" => "Ralat Sistem: " . $e->getMessage()
        ]);
    }
    $conn->close();
}
?>