###
# GLOBALS
###
""" Mapping from process id's to DataEndpoints"""
const out_refs = Dict{ProcID,Endpoint}()

"""Mapping from process id's to DataEndpoints"""
const in_refs = Dict{ProcID,Endpoint}()

"""Mapping from process id's to caches for outgoing vertex-message caches"""
const vm_caches = Dict{ProcID,Batch{VertexPayload}}()

"""Vector of incoming message queues"""
const vm_buffers = Batch{VertexPayload}()

"""Queue for incoming messages"""
const in_queue = Batch{Message}()

###
# REGISTRATIONS
###
"""Run by a process remotely to fetch its in-endpoint"""
function fetchrefs(pid::ProcID)
    global in_refs
    rref = RemoteChannel(()->Channel{Message}(BUFFER_LENGTH), myid())
    in_refs[pid] = rref
    return rref
end

"""Fetch Endpoints from other all the processes"""
function register()
    global out_refs
    for pid in procs()
        out_refs[pid] = remotecall_fetch(fetchrefs, pid, myid())
    end
end

"""Prompt all processes to register themselves and load relevant tasks"""
function minitialize()
    for pid in procs()
        remotecall_fetch(register, pid)
    end
end

###
# SEND MESSAGES
###
"""Place the vertex payload into cache"""
function cachepayload(vp::VertexPayload, dest_proc::ProcID)
    global vm_caches
    push!(get!(vm_caches, dest_proc, Batch{VertexPayload}()), vp)
    nothing
end

"""Send data messages asynchronously"""
function sendmessage(m::Message)
    global out_refs, vm_caches
    dest_pid::ProcID = getdest(m)
    rref = try
        out_refs[dest_pid]
    catch
        error("Proc $(myid()) isn't registered with proc $dest_pid")
    end
    put!(rref, m)
    nothing
end

"""Synchronously send cached vertex payloads"""
function syncmessages()
    global out_refs, vm_caches
    for pid in keys(vm_caches)
        vm = VertexMessage(pid, copy(vm_caches[pid]))
        sendmessage(vm)
    end
    empty!(vm_caches)
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
    global in_refs
    for (pid,lref) in in_refs
        while isready(lref)
            m::Message = take!(lref)
            push!(in_queue, m)
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
