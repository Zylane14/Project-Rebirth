extends Label

func _process(_delta):
	text = "Gold : " + str(SaveData.gold) #keeps track of gold amount
