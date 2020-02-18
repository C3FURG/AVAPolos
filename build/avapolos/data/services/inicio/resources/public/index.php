<?php
if ((!file_exists('name') && !file_exists('ip')) || (file_exists('name'))) {
	$access_mode="name";
} else {
	$access_mode="ip";
}

switch ($access_mode) {
	case 'name':
		$moodle_url="http://moodle.avapolos";
		$wiki_url="http://wiki.avapolos";
		$educapes_url="http://educapes.avapolos/jspui";
		$downloads_url="http://downloads.avapolos";
		break;

	case 'ip':
		$moodle_url="http://{IP}:81";
		$wiki_url="http://{IP}:82";
		$educapes_url="http://{IP}:83/jspui";
		$downloads_url="http://{IP}:84";
		break;

	default:
		die("Error");
		break;
}
?>

<html>
	<head>
		<title></title>
		 <link rel="stylesheet" type="text/css" href="css/style.css">
	</head>

	<body>


		<div class="wrap">
			<a href="<?php echo $educapes_url; ?>"><div></div></a>
			<a href="<?php echo $moodle_url; ?>"><div></div></a>
			<a href="<?php echo $wiki_url; ?>"><div></div></a>
			<a href="<?php echo $downloads_url; ?>"><div></div></a>
			<a href="#"><div></div></a>
		</div>
	</body>

</html>
