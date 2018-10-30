<?php

require_once("/usr/share/php/CAS.php");
phpCAS::setDebug();
$host = $_SERVER{'SERVER_NAME'};
$host_components = explode( ".", $host);
$cas_host = "auth.".$host_components[1].".".$host_components[2];
$cas_port = 443;
$cas_context = "/cas";

phpCAS::client(CAS_VERSION_2_0, $cas_host, $cas_port, $cas_context);

phpCAS::setNoCasServerValidation();
phpCAS::forceAuthentication();

if (isset($_REQUEST['logout'])) {
    phpCAS::logout();
}

?>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>CAS PHP test</title>
</head>
<body>
<h1>CAS PHP test</h1>
<p>The user's login is <b><?php echo phpCAS::getUser(); ?></b>.</p>
<h3>User Attributes</h3>
<ul>
<?php
foreach (phpCAS::getAttributes() as $key => $value) {
    if (is_array($value)) {
        echo '<li>', $key, ':<ol>';
        foreach ($value as $item) {
            echo '<li><strong>', $item, '</strong></li>';
        }
        echo '</ol></li>';
    } else {
        echo '<li>', $key, ': <strong>', $value, '</strong></li>' . PHP_EOL;
    }
}
    ?>
</ul>
<p>phpCAS version is <b><?php echo phpCAS::getVersion(); ?></b>.</p>
<p><a href="?logout=">Logout</a></p>
</body>
</html>

