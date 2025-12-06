<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
	http_response_code(405);
	echo json_encode(array('error' => 'Method Not Allowed'));
	exit();
}

$userid = $_POST['userid'];
$petName = $_POST['name'];
$petType = $_POST['types'];
$category = $_POST['category'];
$description = $_POST['descriptions'];
$encodedimage = base64_decode($_POST['image']);
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$createdAt = date("Y-m-d H:i:s");

// Insert first (image_path temporarily empty)
$sqlinsertservice = "INSERT INTO tbl_pets 
(user_id, pet_name, pet_type, category, descriptions, image_path, lat, lng, created_at) 
VALUES 
('$userid','$petName','$petType','$category','$description','', '$latitude','$longitude','$createdAt')";

try{
	if ($conn->query($sqlinsertservice) === TRUE){

		// Save image file
		$last_id = $conn->insert_id;
		$path = "../assets/pets/pets_".$last_id.".png";
		file_put_contents($path, $encodedimage);

		// Update image_path in DB
		$sqlupdate = "UPDATE tbl_pets SET image_path='$path' WHERE pet_id='$last_id'";
		$conn->query($sqlupdate);

		$response = array('status' => 'success', 'message' => 'Pet added successfully');
		sendJsonResponse($response);

	}else{
		$response = array('status' => 'failed', 'message' => 'Pet not added');
		sendJsonResponse($response);
	}
}catch(Exception $e){
	$response = array('status' => 'failed', 'message' => $e->getMessage());
	sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
	header('Content-Type: application/json');
	echo json_encode($sentArray);
}
?>
