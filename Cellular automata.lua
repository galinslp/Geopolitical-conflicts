War = Model{
	finalTime = 250,
	dim = 4,
	init = function(model)
		model.cell = Cell{
            conflicts = 0,
            counter = 0,
            state = 0,
            agent = 0,
			init = function(cell)
				--local random = Random()
                --cell.conflicts = random:number()
                cell.conflicts = 0.5
			end,
			execute = function(cell)
                if cell.past.state >= 1 then
                    local conflict_probability = cell.past.conflicts
					forEachNeighbor(cell, function(neigh)
						if neigh.past.state >= 1 then
                            conflict_probability = cell.past.conflicts*neigh.past.conflicts
						end
					end)
                    local bernoulli = Random{p = conflict_probability}
                    local action = (bernoulli:sample() and 1 or 0)
                    cell.counter = cell.past.counter + action
                    if(action > 0) then
                       cell.past.conflicts = (cell.past.conflicts*cell.counter)/(cell.past.conflicts*cell.counter + (1-cell.past.conflicts))
                    end
                    if cell.past.counter == 15 then
                        cell.state = 2
                    elseif cell.past.counter == 30 then
                        cell.state = 3
                    end
                    if ((math.fmod(cell.x,2) == 0 and math.fmod(cell.y,2) == 0) or (math.fmod(cell.x,2) ~= 0 and math.fmod(cell.y,2) ~= 0)) then
                       cell.agent = 1
                    end
                else
                    forEachNeighbor(cell, function(neigh)
						if neigh.past.state >= 2 then
                            cell.state = 1
						end
					end)
                end
                if ((cell.x == 0 and cell.y == 0) or (cell.x == 0 and cell.y == 3) or (cell.x == 3 and cell.y == 0) or (cell.x == 3 and cell.y == 3)) then
                       cell.agent = 2
                       cell.state = 0
                       cell.conflicts = 0
                end
			end
		}

		model.cs = CellularSpace{
			xdim = model.dim,
			instance = model.cell
		}

        model.cs:get(2,2).state = 1
        model.cs:get(1,1).state = 1
        model.cs:get(1,2).state = 1
        model.cs:get(2,1).state = 1

		model.cs:createNeighborhood{strategy = "vonneumann"}

		model.map = Map{
			target = model.cs,
			select = "state",
			min = 0,
			max = 3,
			slices = 4,
            color = "Red"
		}

        model.activatedCells = Map{
			target = model.cs,
			select = "agent",
            value = {0, 1, 2},
            color = {"white","black", "gray"}
		}

		model.timer = Timer{
			Event{action = model.cs},
            Event{action = model.activatedCells},
			Event{action = model.map}
		}
	end
}

war = War
war:run()
