<?php
  $action = (isset($_REQUEST['action']) ? $_REQUEST['action'] : false);
  switch($action)
  {
    case false:
    default:
      header('Location: users.php');
      break;
    case 'Confirm Delete':
      delete_user();
      break;
    case 'Delete User':
      print(confirm_delete_user());
      break;
    case 'Edit User':
      print(try_user_edit());
      break;
    case 'Add User':
      print(print_user_form());
      break;
    case 'Edit':
    case 'Add':
      $retval = try_user_add($action);
      if ($retval === false)
      {
        header('Location: users.php');
      }
      else
      {
        print $retval;
      }
      break;
  }

function print_user_form($message = "", $name = "", $groups = "", $action='Add')
{
  $retval = file_get_contents('header.html');
  $retval .= " <title>${action} User - Remote Home Base Station</title>\n";
  $retval .= " </head>\n <body>\n";
  $retval .= $message;
  $retval .= "  <h1>${action} user</h1>\n";
  $retval .= "  <form action=\"user_update.php\" method=\"POST\">\n";
  $retval .= "   <label for=\"name\">User Login:</label>\n";
  $retval .= "   <input type=\"text\" class=\"name\" name=\"name\" id=\"name\" value=\"${name}\"/>\n";
  $retval .= "   <label for=\"groups\">Group:</label>\n";
  $retval .= "   <input type=\"text\" class=\"groups\" id=\"groups\" name=\"groups\" value=\"${groups}\"/>\n";
  if ($name)
  {
    $retval .= "   <input type='hidden' value='${name}' name='old_name'/>";
  }
  $retval .= "   <input type='submit' value='${action}' name='action' />\n";
  $retval .= "  </form>\n";
  $retval .= " </body>\n";
  $retval .= "</html>\n";
  return $retval;
}
function try_user_add($action)
{
  $name = isset($_REQUEST['name']) ? filter_var($_REQUEST['name'], FILTER_SANITIZE_MAGIC_QUOTES) : false;
  $groups = isset($_REQUEST['groups']) ? filter_var($_REQUEST['groups'],FILTER_SANITIZE_MAGIC_QUOTES) : false;
  $fp = fopen('users.ini', 'r+');
  flock($fp, LOCK_EX);
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  if($name && $groups)
  {
    if(array_key_exists($name, $users) && $action == 'Add')
    {
      return print_user_form("User already exists. Please enter a unique login.", $name, $groups);
    }
    else
    {
      if (isset($_REQUEST['old_name']))
      {
        unset($users[$_REQUEST['old_name']]);
      }
      $users[$name] = array( 'group' => $groups);
      $retval = write_ini($users);
      if (!fwrite($fp, $retval))
      {
        print($retval);
      }
      else
      {
        $retval = false;
      }
    }
  }
  else
  {
    $retval = print_user_form("Please enter all fields.", $name, $groups, $action);
  }
  return $retval;
}

function write_ini($array)
{
  $str = "";
  foreach ($array as $section => $values)
  {
    $str .= "[${section}]\n";
    foreach ($values as $key => $value)
    {
      $str .= "${key} = ${value}\n";
    }
  }
  return $str;
}

function try_user_edit()
{
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  $group = $users[$_REQUEST['name']]['group'];
  if(isset($_REQUEST['name']))
  {
    return print_user_form('',$_REQUEST['name'],$group,'Edit');
  }
  else
  {
    header('Location: users.php');
  }
}

function confirm_delete_user()
{
  $name = (isset($_REQUEST['name']) ? $_REQUEST['name'] : false);
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  if(count($users) <= 1 || $name === false)
  {
    header('Location: users.php');
  }
  else
  {
    $topmatter = file_get_contents('header.html');
    $header = " <title>Confirm User Deletion - Remote Home Base Station</title>\n";
    $header .= " </head>\n";
    $body = " <body>\n";
    $body .= "  <p>Are you sure you want to delete ${name}? The user will no longer be able to log in after this.</p>\n";
    $body .= "  <form action='user_update.php' method=\"POST\">\n";
    $body .= "   <input type='hidden' name='name' value=\"${name}\"/>\n";
    $body .= "   <input type=\"submit\" name=\"action\" value=\"Confirm Delete\"/>\n";
    $body .= "   <input type=\"submit\" name=\"action\" value=\"Cancel\"/>\n";
    $body .= "  </form>\n";
  }
  return $header . $body;
}
function delete_user()
{
  $name = isset($_REQUEST['name']) ? $_REQUEST['name'] : false;
  $users = parse_ini_file('users.ini', true, INI_SCANNER_RAW);
  $fp = fopen('users.ini', 'r+');
  if( $users && $name !== false && $fp)
  {
    flock($fp, LOCK_EX);
    unset($users[$name]);
    $retval = write_ini($users);
    fwrite($fp, $retval);
  }
  header('Location: users.php');
}
?>
