# Test Vertex
id = 5
label = "5"
active = true
fadjlist = [1, 2, 3, 4]
badjlist = [1, 2, 3, 4]
property = NullProperty()
v = Vertex(id, label, active, fadjlist, badjlist, property)

# Test getters
@test getid(v) == id
@test getlabel(v) == label
@test isactive(v) == active
@test getfadj(v) == fadjlist
@test getbadj(v) == badjlist
@test isa(getproperty(v), NullProperty)

# Test setters
@test setlabel!(v, "6") == "6"
@test activate!(v) == true
@test deactivate!(v) == false
@test setfadj!(v, [1]) == [1]
@test setbadj!(v, [2]) == [2]

# Todo: tests on propery
