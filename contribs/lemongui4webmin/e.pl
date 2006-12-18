    my $__param  = [
        {name => 'lemonldapportal',
         type =>'IMPLIED',}  ,
        {name =>  'lemonldapbasepub',
	 type => 'IMPLIED',},
        {name => 'lemonldapbasepriv', 
	 type => 'IMPLIED',},
		    {name => 'lemonldapdomain',
         type => 'REQUIRED' },
		    {name => 'lemonldaphandlerid',
          type => 'REQUIRED' },
	       
	 {name => 'lemonldapconfig',
          type => 'REQUIRED' },
		    {name => 'lemonldapconfigipckey',
          type => 'REQUIRED',default =>'CONF'  },
        {name =>  'lemonldapconfigttl',
         type => 'REQUIRED'},
	{name =>'lemonldapenabledproxy',
	 type => 'IMPLIED',},
{name =>'lemonldapipckey', 
	 type => 'IMPLIED',},
{name => 'lemonldapipcnb' ,
	 type => 'IMPLIED',},
{name => 'lemonldapattrldap',
	 type => 'IMPLIED',},
{name => 'lemonldapcodeappli',
	 type => 'IMPLIED',},
{name =>        'lemonldapdisabled',
  liste =>[0|1], default =>'0',	

	 type => 'IMPLIED',},

{name => 'lemonldapsession',
	 type => 'IMPLIED',},
{name => 'lemonldapstopcookie',
  liste =>[0|1], default =>'0',	
   type => 'IMPLIED',},
{name =>        'lemonldaprecursive',
  liste =>[0|1], default =>'0',	

	 type => 'IMPLIED',},
{name => 'lemonldapproxyext',
	 type => 'IMPLIED',},
{name => 'lemonldapics',
	 type => 'IMPLIED',},
 {name =>'lemonldapmultihoming',
	 type => 'IMPLIED',},


];


