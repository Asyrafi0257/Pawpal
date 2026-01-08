<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (!isset($_GET['user_id'])) {
        $response = array('status' => 'failed', 'message' => 'Bad Request');
        sendJsonResponse($response);
        exit();
    }
    include 'dbconnect.php';

    $user_id = $_GET['user_id'];

    $sqluser = "SELECT 
        *
        FROM tbl_users 
        WHERE user_id = '$user_id'";

    $result = $conn->query($sqluser);

    if ($result->num_rows > 0) {
    $userdata = array(); // initialize dulu
    while ($row = $result->fetch_assoc()) {
        $userdata[] = $row;
    }
    $response = array('status' => 'success', 'message' => 'Success', 'data' => $userdata);
    sendJsonResponse($response);
    }
    else {
        $response = array('status' => 'failed', 'message' => 'Invalid request', 'data' => null);
        sendJsonResponse($response);
    }
} else {
    $response = array('status' => 'bad', 'message' => 'Bad Request');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}