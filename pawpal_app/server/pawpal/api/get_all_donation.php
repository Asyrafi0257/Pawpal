<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

include_once("dbconnect.php");

if (!isset($_GET['user_id']) || empty($_GET['user_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "User ID is required"
    ]);
    exit;
}

$user_id = trim($_GET['user_id']);

try {
    // Query hanya fokus kepada tbl_donations sahaja
    $sql = "SELECT 
                donation_id,
                user_id,
                pet_id,
                donation_type,
                description,
                status,
                created_at,
                updated_at
            FROM tbl_donations
            WHERE user_id = ? 
            ORDER BY created_at DESC";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $donations = [];
    if ($result->num_rows > 0) {
        while ($row = $result->fetch_assoc()) {
            $donations[] = $row;
        }
        echo json_encode([
            "status" => "success",
            "data" => $donations,
            "count" => count($donations)
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "data" => [],
            "count" => 0,
            "message" => "No donations found for user: " . $user_id
        ]);
    }
    
    $stmt->close();
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}

$conn->close();
?>