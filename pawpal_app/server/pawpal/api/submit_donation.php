<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // 1. Ambil data POST
    $user_id = $_POST['user_id'] ?? '';
    $pet_id = $_POST['pet_id'] ?? '';
    $donation_type = $_POST['donation_type'] ?? 'Money';
    $amount = $_POST['amount'] ?? '0.00';
    
    // Kita simpan RM dalam description untuk paparan resit, 
    // tapi pastikan ada kolum 'amount' dalam database jika ingin buat kiraan matematik.
    $description =  " RM " . $amount ; 

    // 2. Validasi ringkas
    if (empty($user_id) || empty($pet_id) || empty($amount)) {
        echo json_encode([
            "status" => "failed", 
            "message" => "Maklumat pembayaran tidak lengkap."
        ]);
        exit;
    }

    // 3. Gunakan Prepared Statement (Lebih selamat daripada real_escape_string)
    $stmt = $conn->prepare("INSERT INTO tbl_donations (user_id, pet_id, donation_type, description, status, created_at) VALUES (?, ?, ?, ?, 'completed', NOW())");
    
    // "iiss" -> user_id (int), pet_id (int), donation_type (string), description (string)
    $stmt->bind_param("iiss", $user_id, $pet_id, $donation_type, $description);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Bayaran berjaya direkodkan.",
            "donation_id" => $conn->insert_id // Hantar ID ini balik ke Flutter untuk Resit
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
        "message" => "Metod permintaan tidak sah."
    ]);
}
?>