
function onInit()
	registerMenuItem("Assign","arrangedice",3)
	registerMenuItem("D4","d4labeled",3,1)
	registerMenuItem("D6","d6labeled",3,2)
	registerMenuItem("D8","d8labeled",3,3)
	registerMenuItem("D10","d10labeled",3,4)
	registerMenuItem("D12","d12labeled",3,5)
end
function onMenuSelection(i,j)
	if(i==3) then
		dice=""
		if j==1 then
			dice="d4"
		elseif j==2 then
			dice="d6"
		elseif j==3 then
			dice="d8"
		elseif j==4 then
			dice="d10"
		elseif j==5 then
			dice="d12"
		end
		setDice({dice})
	end
end

function onDrop(x,y,dragdata)
	if isReadOnly() then
		return false;
	end
	if dragdata.getType() == "dice" then
		reset();
		newDie = dragdata.getDieList()[1];
		setDice(newDie);
		return true;
	end
	return false;
end
