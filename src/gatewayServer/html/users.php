<?php
  $topmatter = file_get_contents('header.html');
  $title = $topmatter . "  <title>User Menu - Remote Home Base Station</title>\n </head>\n <body>\n";
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  if ($users === False)
  {
    $content = "<p class='error'>Something went wrong, and we could not open the users.ini file for you. A new, empty users file will be made for you, so feel free to add any users you want. If you have already added users to this system, please contact customer service.</p>\n";
  }
  else
  {
    $content = "<h1>Users</h1>\n";
  }
  if(isset($_REQUEST['action']) && $_REQUEST['action'] == 'Delete User')
  {
    $body .= "<p class=\"error\">You cannot delete the last user.</p>\n";
  }
  $content .= "<form action='user_update.php' method='POST'>\n";
  $content .= " <select name='name'>\n";
  foreach ($users as $user => $attrlist)
  {
    $content .= "  <option>$user</option>\n";
  }
  $content .= " </select>\n";
  $content .= " <input type='submit' name='action' value='Edit User' />\n";
  $content .= " <input type='submit' name='action' value='Delete User'/>\n";
  $content .= "</form>\n";
  $content .= "<form action='user_update.php' method='POST'>\n";
  $content .= " <input type='submit' name='action' value='Add User'/>\n";
  $content .= "</form>\n";
  $content .= "</body>\n";
  $content .= "</html>\n";
  print $title;
  print $content;
?>
