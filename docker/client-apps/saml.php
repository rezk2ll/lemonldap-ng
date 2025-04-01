<?php

echo "This is a SAML-protected application";
echo "<br/><br/>";
echo "Connected as " . $_SERVER['MELLON_uid'] . " (" . $_SERVER['MELLON_name'] . " &lt;" . $_SERVER['MELLON_e-mail'] . "&gt;" . ")";
echo "<br/>";
echo "Member of the following groups:";
echo "<ul>";
foreach (explode(':', $_SERVER['MELLON_groups']) as $group) {
	echo "<li>" . $group . "</li>";
}
echo "</ul>";
