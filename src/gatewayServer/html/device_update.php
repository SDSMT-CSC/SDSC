<?php
  $action = (isset($_REQUEST['action']) ? $_REQUEST['action'] : false);
  switch($action)
  {
    case false:
    default:
      header('Location: devices.php');
      break;
    case 'Confirm Delete':
      delete_device();
      break;
    case 'Delete Device':
      print(confirm_delete_device());
      break;
    case 'Edit Device':
      print(try_device_edit());
      break;
    case 'Add Device':
      print(print_device_form());
      break;
    case 'Edit':
    case 'Add':
      $retval = try_device_add($action);
      if ($retval === false)
      {
        header('Location: devices.php');
      }
      else
      {
        print $retval;
      }
      break;
  }

function print_device_form($message = "", $name = "", $groups = "", $action='Add', $interface = "")
{
  $retval = file_get_contents('header.html');
  $retval .= " <title>${action} Device - Remote Home Base Station</title>\n";
  $retval .= " </head>\n <body>\n";
  $retval .= $message;
  $retval .= "  <h1>${action} device</h1>\n";
  $retval .= "  <form action=\"device_update.php\" method=\"POST\">\n";
  $retval .= "   <label for=\"name\">Device Name:</label>\n";
  $retval .= "   <input type=\"text\" name=\"name\" id=\"name\" value=\"${name}\"/>\n";
  $retval .= "   <label for=\"groups\">Group:</label>\n";
  $retval .= "   <input type=\"text\" id=\"groups\" name=\"groups\" value=\"${groups}\"/>\n";
  $retval .= "   <label for=\"interface\">Interface:</label>\n";
  $retval .= "   <input type=\"text\" id=\"interface\" name=\"interface\" value=\"${interface}\"/>\n";
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
function try_device_add($action)
{
  $name = isset($_REQUEST['name']) ? filter_var($_REQUEST['name'], FILTER_SANITIZE_FULL_SPECIAL_CHARS) : false;
  $groups = isset($_REQUEST['groups']) ? filter_var($_REQUEST['groups'],FILTER_SANITIZE_FULL_SPECIAL_CHARS) : false;
  $interface = isset($_REQUEST['interface']) ? filter_var($_REQUEST['interface'], FILTER_SANITIZE_FULL_SPECIAL_CHARS) : "";
  $fp = fopen('devices.ini', 'r+');
  flock($fp, LOCK_EX);
  $devices = parse_ini_file('devices.ini', true, INI_SCANNER_RAW);
  if($name && $groups)
  {
    if(array_key_exists($name, $devices) && $action == 'Add')
    {
      return print_device_form("Device name already exists. Please enter a unique device name.", $name, $groups);
    }
    else
    {
      if (isset($_REQUEST['old_name']))
      {
        unset($devices[$_REQUEST['old_name']]);
      }
      $devices[$_REQUEST['name']] = array( 'group' => $_REQUEST['groups'], 'interface' => $_REQUEST['interface']);
      $retval = write_ini($devices);
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
    $retval = print_device_form("Please enter all fields.", $name, $groups, $action, $interface);
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

function try_device_edit()
{
  $devices = parse_ini_file('devices.ini', true, INI_SCANNER_RAW);
  $group = $devices[$_REQUEST['name']]['group'];
  $interface = $devices[$_REQUEST['name']]['interface'];
  if(isset($_REQUEST['name']))
  {
    return print_device_form('',$_REQUEST['name'],$group,'Edit', $interface);
  }
  else
  {
    header('Location: devices.php');
  }
}

function confirm_delete_device()
{
  $name = (isset($_REQUEST['name']) ? $_REQUEST['name'] : false);
  $devices = parse_ini_file('devices.ini', true, INI_SCANNER_RAW);
  if(count($devices) <= 1 || $name === false)
  {
    header('Location: devices.php');
  }
  else
  {
    $topmatter = file_get_contents('header.html');
    $header = " <title>Confirm Device Deletion - Remote Home Base Station</title>\n";
    $header .= " </head>\n";
    $body = " <body>\n";
    $body .= "  <p>Are you sure you want to delete ${name}? The device will no longer be able to be controlled by the base station after this.</p>\n";
    $body .= "  <form action='device_update.php' method=\"POST\">\n";
    $body .= "   <input type='hidden' name='name' value=\"${name}\"/>\n";
    $body .= "   <input type=\"submit\" name=\"action\" value=\"Confirm Delete\"/>\n";
    $body .= "   <input type=\"submit\" name=\"action\" value=\"Cancel\"/>\n";
    $body .= "  </form>\n";
  }
  return $header . $body;
}
function delete_device()
{
  $name = isset($_REQUEST['name']) ? $_REQUEST['name'] : false;
  $devices = parse_ini_file('devices.ini', true, INI_SCANNER_RAW);
  $fp = fopen('devices.ini', 'r+');
  if( $devices && $name !== false && $fp)
  {
    flock($fp, LOCK_EX);
    unset($devices[$name]);
    $retval = write_ini($devices);
    fwrite($fp, $retval);
  }
  header('Location: devices.php');
}
?>
