export minitialize

###
# GLOBALS
###
"""Endpoint for incoming control messages"""
const cin_ref = RemoteChannel(()->Channel{ControlMessage}(BUFFER_LENGTH), myid())

"""Mapping from process id's to remote ControlEndpoints"""
const cout_refs = Dict{ProcID,ControlEndpoint}()

""" Mapping from process id's to DataEndpoints"""
const dout_refs = Dict{ProcID,DataEndpoint}()

"""Mapping from process id's to DataEndpoints"""
const din_refs = Dict{ProcID,DataEndpoint}()

"""Mapping from process id's to caches for outgoing vertex messages"""
const proc_out_queue = Dict{ProcID,Batch{VertexPayload}}()

"""Vector of incoming message queues"""
const vertex_in_queue = Vector{Vector{VertexPayload}}()

"""Queue for incoming data messages"""
const data_in_queue = Batch{DataMessage}()

###
# REGISTRATIONS
###
"""Run by a process remotely to fetch its remote Endpoints"""
function fetchrefs(pid::ProcID)
    global cin_ref, din_refs
    din_ref = RemoteChannel(()->Channel{DataMessage}(BUFFER_LENGTH), myid())
    din_refs[pid] = din_ref
    return (cin_ref, din_ref)
end

"""Fetch Endpoints from other all the processes"""
function register()
    global cout_refs, dout_refs
    for pid in procs()
        cout_refs[pid], dout_refs[pid] = remotecall_fetch(fetchrefs, pid, myid())
    end
end

###
# SEND MESSAGES
###
"""Place the vertex payload into cache"""
function cachepayload(vp::VertexPayload, dest_proc::ProcID)
    global proc_out_queue
    push!(proc_out_queue[dest_proc], vp)
end

"""Send data messages asynchronously"""
function sendmessage(dm::DataMessage)
    global dout_refs, proc_out_queue
    dest_pid::ProcID = getdest(dm)
    out_ref = try
        dout_refs[dest_pid]
    catch
        error("Proc $(myid()) isn't registered with proc $dest_pid")
    end
    put!(out_ref, dm)
    nothing
end

"""Synchronously send cached vertex payloads"""
function syncmessages()
    global dout_refs, proc_out_queue
    for pid in keys(proc_out_queue)
        vm = VertexMessage(pid, copy(proc_out_queue[pid]))
        put!(dout_refs[dest_pid], vm)
    end
    empty!(proc_out_queue)
    nothing
end

"""Asynchronously send all control messages"""
function sendmessage(cm::ControlMessage)
    global cout_refs
    dest_pid::ProcID = getdest(cm)
    put!(cout_refs[dest_pid], dm)
    nothing
end

###
# RECIEVE DATA MESSAGES
###
"""
Remove all incoming data messages from the local references and place them in
data_in_queue
"""
function receivemessages()
    global din_refs
    for (pid,lref) in din_refs
        while isready(lref)
            m::DataMessage = take!(lref)
            push!(data_in_queue, m)
        end
    end
end

# ###
# # SYNCHRONIZATION
# ###
# """Signal the end of a workers execution"""
# function barrier_signal(mint::MessageInterface, w::Int=myid())
#     put!(get_lock(mint,w), true)
# end
#
# """Wait for all workers to signal (should be called on the main proc only)"""
# function barrier_wait(mint::MessageInterface)
#     for w in workers()
#         take!(get_lock(mint, w))
#     end
# end
