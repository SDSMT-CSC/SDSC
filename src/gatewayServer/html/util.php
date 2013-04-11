<?php
  $links = array('Users'=>'users.php', 'Devices'=>'devices.php');
  function format_from_ini($value, $ini)
  {
    $ini_values = parse_ini_file($ini, true, INI_SCANNER_RAW);
    if(isset($ini_values[$value]))
    {
      if(isset($_REQUEST['name']))
      {
        $_REQUEST['old_name'] = $_REQUEST['name'];
      }
      foreach($ini_values[$value] as $name => $assoc)
      {
        $_REQUEST[$name] = $assoc;
      }
      return true;
    }
    else
    {
      return false;
    }
  }
  function write_ini_str($array)
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
  function is_r_set($var)
  {
    return isset($_REQUEST[$var]) ? $_REQUEST[$var] : false;
  }
  function get_header($title, $file = 'header.html')
  {
    $retval = file_get_contents($file);
    $retval .= "  <title>${title}</title>\n";
    $retval .= " </head>\n";
    return $retval;
  }
  function get_content_head()
  {
    global $links;
    $retval = " <body>\n";
    $retval .= "  <div class='topbar'>Remote Home Base Station</div>\n";
    $retval .= "  <div class='leftbar'>\n";
    $retval .= "   <ul>\n";
    foreach($links as $link => $href)
    {
      $retval .= "    <li><a href=\"$href\">$link</a></li>\n";
    }
    $retval .= "   </ul>\n";
    $retval .= "  </div>\n";
    $retval .= "  <div class='content'>\n";
    return $retval;
  }
  function get_content_tail()
  {
    $retval = "  </div>\n";
    $retval .= " </body>\n";
    $retval .= "</html>\n";
    return $retval;
  }
  function print_generic_form($action, $target, $object, $elements)
  {
    $body = get_content_head();
    $body .= "  <h1>${action} ${object}</h1>\n";
    $body .= "  <form action='$target' method='POST'>\n";
    $body .= "   <table>\n";
    foreach($elements as $field)
    {
      $ffield = strtolower(filter_var($field, FILTER_SANITIZE_URL));
      $body .= "   <tr>\n";
      $body .= "   <td>";
      $body .= "    <label for=${ffield}>${field}</label>";
      $body .= "</td><td>";
      $body .= "    <input type=\"text\" name=\"${ffield}\" id=\"${ffield}\"";
      $val = is_r_set($ffield);
      if($val)
      {
        $body .= " value = \"$val\"";
      }
      $body .= "/>";
      $body .= "</td></tr>\n";
    }
    if(isset($_REQUEST['old_name']))
    {
      $old_name = $_REQUEST['old_name'];
      $body .= "   <input type=\"hidden\" value=\"$old_name\" name=\"old_name\"/>\n";
    }
    $body .= "   </table>\n";
    $body .= "   <input type=\"submit\" name=\"action\" value=\"${action}\"/>\n";
    $body .= "  </form>\n";
    return $body;
  }
  function print_generic_menu($menu, $target, $ini_file, $arg_actions, $void_actions)
  {
    $body = get_content_head();
    $body .= "  <h1>$menu</h1>\n";
    $body .= "  <form action=\"$target\" method=\"POST\">\n";
    $body .= "   <select name=\"name\" id=\"name\">\n";
    $ini_input = parse_ini_file($ini_file, true, INI_SCANNER_RAW);
    foreach($ini_input as $action => $args)
    {
      $body .= "    <option>$action</option>\n";
    }
    $body .= "   </select>\n";
    foreach($arg_actions as $action)
    {
      $body .= "   <input type='submit' name=\"action\" value=\"$action\"/>\n";
    }
    $body .= "  </form>\n";
    foreach($void_actions as $action)
    {
      $body .= "  <form action=\"$target\" method=\"POST\">\n";
      $body .= "   <input type='submit' name=\"action\" value=\"$action\"/>\n";
      $body .= "  </form>\n";
    }
    return $body;
  }
  function validate_generic_form($action, $target, $object, $elements, $ini_file)
  {
    /* Make sure all required fields are present. */
    foreach($elements as $field)
    {
      $field_html = strtolower(filter_var($field, FILTER_SANITIZE_URL));
      if(isset($_REQUEST[$field_html]) === false || $_REQUEST[$field_html] == "")
      { 
        $retval = print_generic_form($action, $target, $object, $elements);
        $retval .= "  <p class=\"error\">Please enter all fields ($field).</p>\n";
        return get_header("$action $object") . $retval . get_content_tail();
      }
    }
    /* Read in the data from the ini file for editing. */
    $data = parse_ini_file($ini_file, true, INI_SCANNER_RAW);
    /* If the key may have changed, remove the old key */
    if(isset($_REQUEST['old_name']))
    {
      unset($data[$_REQUEST['old_name']]);
      print $_REQUEST['old_name'];
    }
    /* Add a new key with the values specified in the data passed in. */
    $key = $_REQUEST[strtolower(filter_var($elements[0], FILTER_SANITIZE_URL))];
    print $key;
    print_r($data);
    if(array_key_exists($key, $data))
    {
      $retval = "<p class=\"error\">The identifier $key already exists in the system. Please choose a unique identifier.</p>\n";
      return get_header("$action $object") . print_generic_form($action, $target, $object, $elements) . $retval . get_content_tail();
    }
    foreach(array_slice($elements, 1) as $property)
    {
      $property = strtolower(filter_var($property, FILTER_SANITIZE_URL));
      $data[$key][$property] = $_REQUEST[$property];
    }
    $data = write_ini_str($data);
    $fp = fopen($ini_file, 'r+');
    $lock = flock($fp, LOCK_EX);
    if(fwrite($fp, $data) === false)
    {
      $retval = "<p class=\"error\">An error occurred while writing to the file $ini_file. Changes not saved.</p>\n";
      return get_header("$action $object") . print_generic_form($action, $target, $object, $elements) . $retval . get_content_tail();
    }
    return false;
  }
  function confirm_remove_node($target)
  {
    $retval = get_header('Confirm Delete') . get_content_head();
    $retval .= "   <h1>Confirm Delete</h1>\n";
    $name = filter_var($_REQUEST['name'], FILTER_SANITIZE_FULL_SPECIAL_CHARS);
    $retval .= "   <p>Are you sure you want to delete $name? You will have to re-add it manually later if you change your mind, and this base station won't allow access to it until you do.</p>\n";
    $retval .= "   <form action=\"$target\" method=\"POST\">\n";
    $retval .= "    <input type=\"hidden\" value=\"$name\" name=\"name\"/>\n";
    $retval .= "    <input type=\"submit\" value=\"Confirm ${_REQUEST['action']}\" name=\"action\"/>\n";
    $retval .= "    <input type=\"submit\" value=\"Cancel\" name=\"action\"/>\n";
    $retval .= "   </form>\n";
    $retval .= get_content_tail();
    return $retval;
  }
  function remove_node($target, $ini_file)
  {
    $objects = parse_ini_file($ini_file, true, INI_SCANNER_RAW);
    if(isset($_REQUEST['name']))
    {
      if(isset($objects[$_REQUEST['name']]))
      {
        unset($objects[$_REQUEST['name']]);
        $fp = fopen($ini_file, 'w');
        flock($fp, LOCK_EX);
        $retval = write_ini_str($objects);
        fwrite($fp, $retval);
      }
      else
      {
        $name = filter_var($_REQUEST['name'], FILTER_SANITIZE_HTML_FULL_SPECIAL_CHARS);
        print get_header('Failed to Delete') . get_content_head() . "<p>Failed to delete $name. Please make sure $name exists in the $ini_file file.</p>\n" . get_content_tail();
      }
    }
    else
    {
      return false;
    }
  }
?>
