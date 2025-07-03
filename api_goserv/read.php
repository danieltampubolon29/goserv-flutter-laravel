<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$koneksi = new mysqli('localhost', 'root', '', 'db_goserv');
$query = mysqli_query($koneksi, "SELECT * FROM service");
$data = mysqli_fetch_all($query, MYSQLI_ASSOC);
echo json_encode($data);
