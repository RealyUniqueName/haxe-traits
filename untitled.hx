//IS
{
	expr => ECall({
		expr => EField({
			expr => ECall({
				expr => EField({
					expr => EField({
						expr => EConst(CIdent(traits)), pos => #pos(people/Jack.hx:52: characters 8-14) 
					},Trait), pos => #pos(people/Jack.hx:52: characters 8-20) 
				},parent), pos => #pos(people/Jack.hx:52: characters 8-27) 
			},[{
				expr => EField({
					expr => EField({
						expr => EConst(CIdent(people)), pos => #pos(people/Jack.hx:52: characters 28-34) 
					},jobs), pos => #pos(people/Jack.hx:52: characters 28-39) 
				},TPostman), pos => #pos(people/Jack.hx:52: characters 28-48) 
			}]), pos => #pos(people/Jack.hx:52: characters 8-49) 
		},send), pos => #pos(people/Jack.hx:52: characters 8-54) 
	},[{
		expr => EConst(CIdent(message)), pos => #pos(people/Jack.hx:52: characters 55-62) 
	}]), pos => #pos(people/Jack.hx:52: characters 8-63) 
}


//HAS TO BE
{ 
	expr => ECall({ 
		expr => EField({ 
			expr => EConst(CIdent(this)), 
			pos => #pos(people/Jack.hx:53: characters 8-12) 
		},_people_jobs_TPostman_send), 
		pos => #pos(people/Jack.hx:53: characters 8-39) 
	},[{ 
		expr => EConst(CIdent(message)), 
		pos => #pos(people/Jack.hx:53: characters 40-47) 
	}]), 
	pos => #pos(people/Jack.hx:53: characters 8-48) 
}