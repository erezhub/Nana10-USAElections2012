package com.data
{
	public class Candidate
	{
		private var _id:int;
		private var _name:String;
		public var totalVotes:int = 0;
		
		public function Candidate(candidateID:int, candidateName:String)
		{
			_id = candidateID;
			_name = candidateName;
		}

		public function get id():int
		{
			return _id;
		}

		public function get name():String
		{
			return _name;
		}


	}
}