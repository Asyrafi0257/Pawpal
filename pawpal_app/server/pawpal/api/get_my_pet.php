<?php
header("Access-Control-Allow-Origin: *"); // running as chrome app

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    include 'dbconnect.php';
    
    $results_per_page = 10;
    if ( isset( $_GET[ 'curpage' ] ) ) {
        $curpage = ( int )$_GET[ 'curpage' ];
    } else {
        $curpage = 1;
    }
    $page_first_result = ( $curpage - 1 ) * $results_per_page;

    // Base JOIN query
    $baseQuery = "
        SELECT 
        p.pet_id,
        p.pet_name,
        p.pet_type,
        p.category,
        p.descriptions,
        p.image_path
        FROM tbl_pets p
    ";

    // Search logic
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $sqlloadpet = $baseQuery . "
            WHERE p.pet_name LIKE '%$search%' 
               OR p.pet_type LIKE '%$search%'
               OR p.category LIKE '%$search%'
            ORDER BY p.pet_id DESC";
    } else {
        $sqlloadpet = $baseQuery . " ORDER BY p.pet_id DESC";
    }


    // Execute query
    $result = $conn->query($sqlloadpet);
    $number_of_result = $result->num_rows;
    $number_of_page = ceil( $number_of_result / $results_per_page );

    $sqlloadpet .= " LIMIT $page_first_result, $results_per_page";
    $result = $conn->query($sqlloadpet);

    if ($result && $result->num_rows > 0) {
        $petdata = array();
        while ($row = $result->fetch_assoc()) {
            $petdata[] = $row;
        }
        $response = array('status' => 'success', 'data' => $petdata,'numofpage'=>$number_of_page, 'numberofresult'=>$number_of_result);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null,'numofpage'=>$number_of_page, 'numberofresult'=>$number_of_result);
        sendJsonResponse($response);
    }

} else {
    $response = array('status' => 'failed');
    sendJsonResponse($response);
    exit();
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>