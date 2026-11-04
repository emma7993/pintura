extends SceneTree

func _initialize() -> void:
	var util=load('res://Source/prepare.gd').new()
	var original:=Image.load_from_file('res://Source/headparts_original.png')
	var metrics:Dictionary=JSON.parse_string(FileAccess.get_file_as_string('res://Source/parts_metrics.json'))
	var names:= ['torso','head_front','head_quarter','head_back']
	for i in 4:
		var c:Image=util.cell(original,i,4,1)
		var b:Rect2i=util.bounds(c)
		var cropped:=c.get_region(b)
		cropped.save_png('res://Source/Parts/'+names[i]+'.png')
		var anchor_x:=cropped.get_width()*0.5
		if i==0:
			var total:=0.0
			var count:=0
			for y in range(roundi(cropped.get_height()*0.88),roundi(cropped.get_height()*0.97)):
				for x in cropped.get_width():
					if cropped.get_pixel(x,y).a>=0.5:
						total+=x
						count+=1
			anchor_x=total/maxi(1,count)
		metrics[names[i]]={'size':[cropped.get_width(),cropped.get_height()],'root_x':anchor_x,'source_bounds':str(b)}
	var out:=FileAccess.open('res://Source/parts_metrics.json',FileAccess.WRITE)
	out.store_string(JSON.stringify(metrics,'\t'))
	util.free()
	print('HEADS PASS: fixed torso and 3 raster head poses')
	quit()
