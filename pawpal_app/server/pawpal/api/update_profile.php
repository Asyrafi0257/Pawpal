<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'failed', 'message' => 'Method Not Allowed']);
    exit();
}

$userid = $_POST['user_id'];
$name   = addslashes($_POST['user_name']);
$phone  = addslashes($_POST['user_phone']);
$email  = addslashes($_POST['user_email']);

try {
    $sqlupdateuser = "UPDATE tbl_users SET 
        user_name = '$name', 
        user_phone = '$phone', 
        user_email = '$email'
        WHERE user_id = '$userid'";

    if ($conn->query($sqlupdateuser) === TRUE) {
        // image part
        if (!empty($_POST['profile_image'])) {
            $base64Image = $_POST['profile_image'];
            if (strpos($base64Image, ',') !== false) {
                $base64Image = explode(',', $base64Image)[1];
            }
            $decodedImage = base64_decode($base64Image);
            if ($decodedImage === false) {
                throw new Exception("Invalid image data");
            }

            $fileName = "profile_" . $userid . ".png";
            $filePath = "../assets/profile/" . $fileName;
            file_put_contents($filePath, $decodedImage);

            $conn->query("UPDATE tbl_users SET profile_image = '$fileName' WHERE user_id = '$userid'");
        }

        // Ambil balik data user terkini
        $sqluser = "SELECT * FROM tbl_users WHERE user_id = '$userid'";
        $result = $conn->query($sqluser);
        $userdata = null;
        if ($result->num_rows > 0) {
            $userdata = $result->fetch_assoc();
            if (!empty($userdata['profile_image'])) {
                $filePath = "../assets/profile/" . $userdata['profile_image'];
                if (!file_exists($filePath)) {
                    $userdata['profile_image'] = "";
                }
            }
        }

        sendJsonResponse([
            'status' => 'success',
            'message' => 'Profile updated successfully',
            'data' => $userdata
        ]);
    } else {
        sendJsonResponse([
            'status' => 'failed',
            'message' => 'Profile update failed'
        ]);
    }
} catch (Exception $e) {
    sendJsonResponse([
        'status' => 'failed',
        'message' => $e->getMessage()
    ]);
}

function sendJsonResponse($sentArray)
{
    echo json_encode($sentArray, JSON_UNESCAPED_SLASHES);
}
?>
