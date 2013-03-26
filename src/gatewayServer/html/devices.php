<?php
  $topmatter = file_get_contents('header.html');
  $title = $topmatter . "  <title>Device Menu - Remote Home Base Station</title>\n </head>\n <body>\n";
  $users = parse_ini_file('devices.ini', true, INI_SCANNER_RAW);
  if ($users === False)
  {
    $content = "<p class='error'>Something went wrong, and we could not open the devices.ini file for you. A new, empty devices file will be made for you, so feel free to add any devices you want. If you have already added devices to this system, please contact customer service.</p>\n";
  }
  else
  {
    $content = "<h1>Devices</h1>\n";
  }
  $content .= "<form action='device_update.php' method='POST'>\n";
  $content .= " <select name='name'>\n";
  foreach ($users as $user => $attrlist)
  {
    $content .= "  <option>$user</option>\n";
  }
  $content .= " </select>\n";
  $content .= " <input type='submit' name='action' value='Edit Device' />\n";
  $content .= " <input type='submit' name='action' value='Delete Device'/>\n";
  $content .= "</form>\n";
  $content .= "<form action='device_update.php' method='POST'>\n";
  $content .= " <input type='submit' name='action' value='Add Device'/>\n";
  $content .= "</form>\n";
  $content .= "</body>\n";
  $content .= "</html>\n";
  print $title;
  print $content;
?>
