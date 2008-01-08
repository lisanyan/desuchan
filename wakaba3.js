var thread_cookie = "o_hidden_threads"; //You can change to custom name.

function get_cookie(name)
{
	with(document.cookie)
	{
		var regexp=new RegExp("(^|;\\s+)"+name+"=(.*?)(;|$)");
		var hit=regexp.exec(document.cookie);
		if(hit&&hit.length>2) return unescape(hit[2]);
		else return '';
	}
};

function set_cookie(name,value,days)
{
	if(days)
	{
		var date=new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires="; expires="+date.toGMTString();
	}
	else expires="";
	document.cookie=name+"="+value+expires+"; path=/";
}

function get_password(name)
{
	var pass=get_cookie(name);
	if(pass) return pass;

	var chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	var pass='';

	for(var i=0;i<8;i++)
	{
		var rnd=Math.floor(Math.random()*chars.length);
		pass+=chars.substring(rnd,rnd+1);
	}

	return(pass);
}



function insert(text)
{
	var textarea=document.forms.postform.comment;
	text = text + "\n";
	if(textarea)
	{
		if(textarea.createTextRange && textarea.caretPos) // IE
		{
			var caretPos=textarea.caretPos;
			caretPos.text=caretPos.text.charAt(caretPos.text.length-1)==" "?text+" ":text;
		}
		else if(textarea.setSelectionRange) // Firefox
		{
			var start=textarea.selectionStart;
			var end=textarea.selectionEnd;
			textarea.value=textarea.value.substr(0,start)+text+textarea.value.substr(end);
			textarea.setSelectionRange(start+text.length,start+text.length);
		}
		else
		{
			textarea.value+=text+" ";
		}
		//textarea.focus();
	}
}

function highlight(post)
{
	var cells=document.getElementsByTagName("td");
	for(var i=0;i<cells.length;i++) if(cells[i].className=="highlight") cells[i].className="reply";

	var reply=document.getElementById("reply"+post);
	if(reply)
	{
		reply.className="highlight";
/*		var match=/^([^#]*)/.exec(document.location.toString());
		document.location=match[1]+"#"+post;*/
		return false;
	}

	return true;
}



function set_stylesheet(styletitle,norefresh)
{
	set_cookie("wakabastyle",styletitle,365);

	var links=document.getElementsByTagName("link");
	var found=false;
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title)
		{
			links[i].disabled=true; // IE needs this to work. IE needs to die.
			if(styletitle==title) { links[i].disabled=false; found=true; }
		}
	}
	if(!found) set_preferred_stylesheet();
}

function set_preferred_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title) links[i].disabled=(rel.indexOf("alt")!=-1);
	}
}

function get_active_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&title&&!links[i].disabled) return title;
	}
	return null;
}

function get_preferred_stylesheet()
{
	var links=document.getElementsByTagName("link");
	for(var i=0;i<links.length;i++)
	{
		var rel=links[i].getAttribute("rel");
		var title=links[i].getAttribute("title");
		if(rel.indexOf("style")!=-1&&rel.indexOf("alt")==-1&&title) return title;
	}
	return null;
}

function set_inputs(id) { with(document.getElementById(id)) {if(!field1.value) field1.value=get_cookie("name"); if(!email.value) email.value=get_cookie("email"); if(!password.value) password.value=get_password("password"); } }
function set_delpass(id) { with(document.getElementById(id)) {password.value=get_cookie("password"); } }


function do_ban(el)
{
	var reason=prompt("Give a reason for this ban:");
	if(reason) document.location=el.href+"&comment="+encodeURIComponent(reason);
	return false;
}

window.onunload=function(e)
{
	if(style_cookie)
	{
		var title=get_active_stylesheet();
		set_cookie(style_cookie,title,365);
	}
}

window.onload=function(e)
{
	var match;

	if(match=/#i([0-9]+)/.exec(document.location.toString()))
	if(!document.forms.postform.comment.value)
	insert(">>"+match[1]);

	if(match=/#([0-9]+)/.exec(document.location.toString()))
	highlight(match[1]);
}

if(style_cookie)
{
	var cookie=get_cookie(style_cookie);
	var title=cookie?cookie:get_preferred_stylesheet();
	set_stylesheet(title);
}

function threadHide(id)
{
	toggleHidden(id);
	add_to_thread_cookie(id);
}

function threadShow(id)
{
	document.getElementById(id).style.display = "";
	var threadInfo = id + "_info";
	document.getElementById(threadInfo).innerHTML = "";
	var hideThreadText = id + "_display";
	document.getElementById(hideThreadText).innerHTML = "<a href=\"javascript:threadHide('"+ id +"')\">(-) Hide Thread</a>";
	remove_from_thread_cookie(id);
}

function add_to_thread_cookie(id)
{
	var hiddenThreadArray = extractFromThreadCookie();
	var addThread = 1;
	for (var i=0; i <= hiddenThreadArray.length; i++)
	{
		if (hiddenThreadArray[i] == id)
		{
			break;
			addThread = 0;
		}
	}
	if (addThread)
	{
		hiddenThreadArray.push(id);
		set_cookie(thread_cookie, hiddenThreadArray.join(","), 365);
	}
}

function remove_from_thread_cookie(id)
{
	var hiddenThreadArray = extractFromThreadCookie();
	var removeThread = 0;
	for (var i=0; i < hiddenThreadArray.length; i++)
	{
		if (removeThread)
		{
			hiddenThreadArray[i-1] = hiddenThreadArray[i];
		}
		else if (hiddenThreadArray[i] == id || hiddenThreadArray == '' || "t" + hiddenThreadArray[i] == id)
		{
			removeThread = 1;
		}
	}
	var shortenedLength = hiddenThreadArray.length - 1;
	hiddenThreadArray.length = shortenedLength;
	set_cookie(thread_cookie, hiddenThreadArray.join(","), 365);
}

function hideThreads()
{
	var hide_thread_array=extractFromThreadCookie();
	for (var i = 0; i < hide_thread_array.length; i++)
	{
		toggleHidden(hide_thread_array[i]);
	}
}

function toggleHidden(id)
{
	var id_split = id.split("");
	if (id_split[0] == "t")
	{
		id_split.reverse();
		var shortenedLength = id_split.length - 1;
		id_split.length = shortenedLength;
		id_split.reverse();
	}
	else
	{
		id = "t" + id; //Compatibility with an earlier mod
	}
	if (document.getElementById(id))
	{
		document.getElementById(id).style.display = "none";
	}
	var thread_name = id_split.join("");
	var threadInfo = id + "_info";
	if (document.getElementById(threadInfo))
	{
		document.getElementById(threadInfo).innerHTML = "<em>Thread " + thread_name + " Hidden.</em>"; 
	}
	var showThreadText = id + "_display";
	if (document.getElementById(showThreadText)) 
	{
		document.getElementById(showThreadText).innerHTML = "<a href=\"javascript:threadShow('"+ id +"')\">(+) Show Thread</a>";
	}
}

function extractFromThreadCookie()
{
	var hiddenThreads=get_cookie(thread_cookie);
	return hiddenThreads.split(',');	
}

function popUp(URL) {
	day = new Date();
	id = day.getTime();
	eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=450,height=300');");
}
function popUpPost(URL) 
{
	day = new Date();
	id = day.getTime();
	eval("page" + id + " = window.open(URL, '" + id + "', 'toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=600,height=350');");
}
function passfield(num, type, script, page) // Bring up Password Field for [Edit] and [Delete] Links
{
	if (document.getElementById('delpostcontent'+num).innerHTML == "")
	{
		// Collapse other fields
		var others=document.getElementsByName("deletepostspan");
		for(var i=0; i<others.length; i++)
		{
			if(others[i].id != "delpostcontent"+num && others[i].innerHTML != "")
			{
				others[i].innerHTML="";
			}
		}
		
		document.getElementById('delpostcontent'+num).innerHTML = '[<label><input type="checkbox" name="fileonly" value="on" /> File Only?] <input type="password" name="password" id="password' + num + '" size="8" autocomplete="off" /> <input value="OK" type="submit" /><input type="hidden" name="task" value="delete" /><input type="hidden" name="delete" value="' + num + '" autocomplete="off"/>';
		document.getElementById('password'+num).value = get_password("password");
	}
	else
	{
		document.getElementById('delpostcontent'+num).innerHTML = "";
	}
}
