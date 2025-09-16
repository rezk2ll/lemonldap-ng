<?php

echo "This is a OIDC-protected application";
echo "<br/><br/>";
$data = json_decode($_SERVER['OIDC_userinfo_json']);
echo "Connected as " . $data->preferred_username . " (" . $data->name . " &lt;" . $data->email . "&gt;" . ")";
echo "<br/>";
echo "Member of the following groups:";
echo "<ul>";
foreach ($data->groups as $group) {
	echo "<li>" . $group . "</li>";
}
echo "</ul>";
