extends StateMachine

class_name PhaseManager

enum RoundPhase { hero, overlord }

enum HeroTurnPhase {
	start,
	equip,
	actions,
	end,
}

enum OverlordTurnPhase {
	start,
	draw,
	monsters,
	end,
}

enum MonsterTurnPhase {
	start,
	actions,
	end,
}

var round_phase = RoundPhase.hero
var hero_turn_phase = HeroTurnPhase.end
var overlord_turn_phase = OverlordTurnPhase.end
var monster_turn_phase = MonsterTurnPhase.end
