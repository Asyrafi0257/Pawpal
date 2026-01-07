<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // Get POST data
    $pet_id = $_POST['pet_id'] ?? '';
    $adopter_id = $_POST['adopter_id'] ?? '';
    $message = $_POST['message'] ?? '';
    
    // Validation: Check for empty fields
    if (empty($pet_id) || empty($adopter_id) || empty($message)) {
        echo json_encode([
            "status" => "failed",
            "message" => "All fields are required"
        ]);
        exit;
    }
    
    // Validate message length
    if (strlen(trim($message)) < 20) {
        echo json_encode([
            "status" => "failed",
            "message" => "Message should be at least 20 characters"
        ]);
        exit;
    }
    
    // Sanitize inputs
    $pet_id = $conn->real_escape_string($pet_id);
    $adopter_id = $conn->real_escape_string($adopter_id);
    $message = $conn->real_escape_string($message);
    
    // Check if pet exists
    $check_pet = "SELECT pet_id, user_id FROM tbl_pets WHERE pet_id = '$pet_id'";
    $result_pet = $conn->query($check_pet);
    
    if ($result_pet->num_rows == 0) {
        echo json_encode([
            "status" => "failed",
            "message" => "Pet not found"
        ]);
        exit;
    }
    
    $pet_data = $result_pet->fetch_assoc();
    $owner_id = $pet_data['user_id'];
    
    // Check if user is trying to adopt their own pet
    if ($owner_id == $adopter_id) {
        echo json_encode([
            "status" => "failed",
            "message" => "You cannot adopt your own pet"
        ]);
        exit;
    }
    
    // Check if user already has a pending or approved request for this pet
    $check_existing = "SELECT request_id, status FROM tbl_adoptions 
                      WHERE pet_id = '$pet_id' 
                      AND adopter_id = '$adopter_id' 
                      AND status IN ('pending', 'approved')";
    $result_existing = $conn->query($check_existing);
    
    if ($result_existing->num_rows > 0) {
        $existing = $result_existing->fetch_assoc();
        echo json_encode([
            "status" => "failed",
            "message" => "You already have a " . $existing['status'] . " request for this pet"
        ]);
        exit;
    }
    
    // Insert adoption request
    $query = "INSERT INTO tbl_adoptions (pet_id, adopter_id, owner_id, message, status, created_at) 
              VALUES ('$pet_id', '$adopter_id', '$owner_id', '$message', 'pending', NOW())";
    
    if ($conn->query($query) === TRUE) {
        echo json_encode([
            "status" => "success",
            "message" => "Adoption request submitted successfully",
            "request_id" => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            "status" => "failed",
            "message" => "Failed to submit adoption request: " . $conn->error
        ]);
    }
    
} else {
    echo json_encode([
        "status" => "failed",
        "message" => "Invalid request method"
    ]);
}
?>