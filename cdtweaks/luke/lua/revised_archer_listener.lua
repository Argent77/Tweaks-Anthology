-- cdtweaks, revised archer kit: +X missile thac0/damage bonus with bows only! --

EEex_Opcode_AddListsResolvedListener(function(sprite)
	-- internal function that applies the actual bonus via "CDFRLNTD.SPL"
	local apply = function(spriteLevel1, spriteLevel2, spriteLevel3)
		-- Update vars
		sprite:setLocalInt("cdtweaksRevisedArcherHelper1", spriteLevel1)
		sprite:setLocalInt("cdtweaksRevisedArcherHelper2", spriteLevel2)
		sprite:setLocalInt("cdtweaksRevisedArcherHelper3", spriteLevel3)
		-- Mark the creature as 'bonus applied'
		sprite:setLocalInt("cdtweaksRevisedArcher", 1)
		--
		sprite:applyEffect({
			["effectID"] = 146, -- Cast spell
			["dwFlags"] = 1, -- Cast instantly (caster level)
			["durationType"] = 1,
			["res"] = "CDFRLNTD",
			["sourceID"] = sprite.m_id,
			["sourceTarget"] = sprite.m_id,
		})
	end
	-- Check creature's equipment / kit
	local equipment = sprite.m_equipment
	local selectedItem = equipment.m_items:get(equipment.m_selectedWeapon)
	local itemHeader = selectedItem.pRes.pHeader
	--
	local kit = GT_Resource_IDSToSymbol["kit"]
	local spriteKit = EEex_BOr(EEex_LShift(sprite.m_baseStats.m_mageSpecUpperWord, 16), sprite.m_baseStats.m_mageSpecialization)
	--
	local itemcat = GT_Resource_IDSToSymbol["itemcat"]
	-- (Bow with arrows equipped || bow with unlimited ammo equipped) && Archer kit
	local applyCondition = (itemcat[itemHeader.itemType] == "ARROW" or itemcat[itemHeader.itemType] == "BOW") and kit[spriteKit] == "FERALAN"
	--
	if sprite:getLocalInt("cdtweaksRevisedArcher") == 0 then
		if applyCondition then
			apply(sprite.m_derivedStats.m_nLevel1, sprite.m_derivedStats.m_nLevel2, sprite.m_derivedStats.m_nLevel3) -- since ``EEex_Opcode_AddListsResolvedListener`` is running after the effect lists have been evaluated, ``m_bonusStats`` has already been added to ``m_derivedStats`` by the engine
		end
	else
		if applyCondition then
			-- Check if level has changed since the last application
			local spriteLevel1 = sprite.m_derivedStats.m_nLevel1
			local spriteLevel2 = sprite.m_derivedStats.m_nLevel2
			local spriteLevel3 = sprite.m_derivedStats.m_nLevel3
			--
			if spriteLevel1 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper1")
				or spriteLevel2 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper2")
				or spriteLevel3 ~= sprite:getLocalInt("cdtweaksRevisedArcherHelper3")
			then
				apply(spriteLevel1, spriteLevel2, spriteLevel3)
			end
		else
			-- Mark the creature as 'bonus removed'
			sprite:setLocalInt("cdtweaksRevisedArcher", 0)
			--
			sprite:applyEffect({
				["effectID"] = 321, -- Remove effects by resource
				["durationType"] = 1,
				["res"] = "CDFRLNTD",
				["sourceID"] = sprite.m_id,
				["sourceTarget"] = sprite.m_id,
			})
		end
	end
end)
