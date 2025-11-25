<?php
    header("Access-Control-Allow-Origin: *"); // running as crome app
   

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        if (!isset($_POST['email']) || !isset($_POST['password'])) {
            $response = array('status' => 'failed', 'message' => 'Bad Request');
            sendJsonResponse($response);
            exit();
        }
        $email = $_POST['email'];
        $password = $_POST['password'];
        $hashedpassword = sha1($password);
        include 'dbconnect.php';
        $sqllogin = "SELECT * FROM `tbl_users` WHERE `user_email` = '$email' AND `user_password` = '$hashedpassword'";
        $result = $conn->query($sqllogin);

        //check if user exists
        if ($result->num_rows > 0) {
            $userdata = array();
            while ($row = $result->fetch_assoc()) {
                $userdata[] = $row;
            }
            $response = array('status' => 'success', 'message' => 'Login successful', 'data' => $userdata);
            sendJsonResponse($response);
        } else {
            $response = array('status' => 'failed', 'message' => 'Invalid email or password','data'=>null);
            sendJsonResponse($response);
        }

    }else{
        $response = array('status' => 'failed', 'message' => 'Method Not Allowed');
        sendJsonResponse($response);
        exit();
    }


 function sendJsonResponse($sentArray)
    {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }
?>