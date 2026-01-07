<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    $query = "
        SELECT 
            p.pet_id,
            p.user_id,
            p.pet_name,
            p.pet_type,
            p.category,
            p.description,
            p.gender,
            p.age,
            p.health,
            p.image_path,
            p.lat,
            p.lng,
            p.created_at,
            u.user_name,
            u.user_email,
            u.user_phone,
            u.reg_date
        FROM tbl_pets p
        JOIN tbl_users u ON p.user_id = u.user_id
    ";

    $conditions = [];

    if (!empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $conditions[] = "(
            p.pet_name LIKE '%$search%'
            OR p.pet_type LIKE '%$search%'
            OR p.category LIKE '%$search%'
            OR p.description LIKE '%$search%'
            OR p.gender LIKE '%$search%'
            OR p.age LIKE '%$search%'
            OR p.health LIKE '%$search%'
        )";
    }

    if (!empty($_GET['filter'])) {
        $filter = $conn->real_escape_string($_GET['filter']);
        $conditions[] = "p.pet_type = '$filter'";
    }

    if (!empty($conditions)) {
        $query .= " WHERE " . implode(" AND ", $conditions);
    }

    $query .= " ORDER BY p.pet_id DESC";

    $result = $conn->query($query);

    if ($result && $result->num_rows > 0) {
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $data]);
    } else {
        echo json_encode(["status" => "failed", "data" => []]);
    }
}
?>
