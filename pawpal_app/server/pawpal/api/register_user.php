<?php
    header("Access-Control-Allow-Origin: *");
    include 'dbconnect.php';

    if ($_SERVER['REQUEST_METHOD'] != 'POST') {
        http_response_code(405);
        echo json_encode(array('error' => 'Method Not Allowed'));
        exit();
    }
    if ( !isset($_POST['name']) || !isset($_POST['email']) ||  !isset($_POST['phone']) || !isset($_POST['password'])) {
        http_response_code(400);
        echo json_encode(array('error' => 'Bad Request'));
        exit();
    }
    //dapatkan data dari client request
	$name = $_POST['name'];
    $email = $_POST['email'];
	$phone = $_POST['phone'];
	$password = $_POST['password'];
	$hashedpassword = sha1($password);

    // Check if email already exists
	$sqlcheckmail = "SELECT * FROM `tbl_users` WHERE `user_email` = '$email'";
	$result = $conn->query($sqlcheckmail);
	if ($result->num_rows > 0){
		$response = array('status' => 'failed', 'message' => 'Email already registered');
		sendJsonResponse($response);
		exit();
	}

    // Insert new user into database
	$sqlregister = "INSERT INTO `tbl_users`(`user_name`, `user_email`, `user_phone`, `user_password`) VALUES ('$name','$email','$phone', '$hashedpassword')";
	try{
		if ($conn->query($sqlregister) === TRUE){
			$response = array('status' => 'success', 'message' => 'User registered successfully');
			sendJsonResponse($response);
		}else{
			$response = array('status' => 'failed', 'message' => 'User registration failed');
			sendJsonResponse($response);
		}
	}catch(Exception $e){
		$response = array('status' => 'failed', 'message' => $e->getMessage());
		sendJsonResponse($response);
	}

    
    //	function to send json response	
    function sendJsonResponse($sentArray)
    {
        header('Content-Type: application/json');
        echo json_encode($sentArray);
    }

?>