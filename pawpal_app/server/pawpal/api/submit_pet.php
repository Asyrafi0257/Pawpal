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
// Accept images as array (decode JSON if needed)
$images = isset($_POST['images']) ? $_POST['images'] : [];
if (is_string($images)) {
	$images = json_decode($images, true);
}
if (!is_array($images)) {
	$images = [$images];
}

// Validate image count
$imageCount = count($images);
if ($imageCount < 1 || $imageCount > 3) {
	http_response_code(400);
	echo json_encode(array('error' => 'You must submit between 1 and 3 images'));
	exit();
}
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];
$createdAt = date("Y-m-d H:i:s");

// Insert first (image_paths temporarily empty)
$sqlinsertservice = "INSERT INTO tbl_pets 
(user_id, pet_name, pet_type, category, description, image_path, lat, lng, created_at) 
VALUES 
('$userid','$petName','$petType','$category','$description','', '$latitude','$longitude','$createdAt')";

try{
	if ($conn->query($sqlinsertservice) === TRUE){
		$last_id = $conn->insert_id;
		$imagePaths = array();
		foreach ($images as $idx => $img) {
			$decoded = base64_decode($img);
			$imgPath = "../assets/pets/pets_".$last_id."_".($idx+1).".png";
			file_put_contents($imgPath, $decoded);
			$imagePaths[] = $imgPath;
		}
		$jsonPaths = json_encode($imagePaths);
		// Update image_path in DB (store as JSON)
		$sqlupdate = "UPDATE tbl_pets SET image_path='$jsonPaths' WHERE pet_id='$last_id'";
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
