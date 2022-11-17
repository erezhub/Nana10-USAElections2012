package com.data
{
	public class State
	{
		private var _id:int;
		private var _name:String;
		private var _abbrevation:String;
		private var _winner:int;
		private var _formerWinner:int;
		private var _electors:int;
		
		public function State(stateId:int,stateName:String,stateAbbervation:String,stateWinner:int,stateFormerWinner:int,stateElectors:int)
		{
			_id = stateId;
			_name = stateName;
			_abbrevation = stateAbbervation;
			_winner = stateWinner;
			_formerWinner = stateFormerWinner;
			_electors = stateElectors;
		}

		public function get id():int
		{
			return _id;
		}

		public function get name():String
		{
			return _name;
		}

		public function get abbrevation():String
		{
			return _abbrevation;
		}

		public function get winner():int
		{
			return _winner;
		}

		public function set winner(value:int):void
		{
			_winner = value;
		}

		public function get formerWinner():int
		{
			return _formerWinner;
		}

		public function get electors():int
		{
			return _electors;
		}


	}
}