**Maintain and update processes**

A few months ago, I walked into a restaurant with a friend to grab a meal. 
The first thing we needed was a menu(to enable us place our orders) which was supposed to be brought by the waiter, 
that process ended up taking over 30 min. As we were was waiting, I noticed some customers walk out without placing 
their orders, their faces displaying disappointment. I wondered how many customers they lost on a daily basis and the 
amount of money they lost on the orders not made because of the inefficiency at the menu provision and order stage.
 
Recently when I was working on Elixir processes, I remembered the restaurant incident and I thought, 
processes can be used to hold state. Therefore, a restaurant menu can always be availed to customers on their table
(perhaps using a screen on the table the restaurants mobile app), with the new delicacies/meals of the day list. The customers would then be able to place orders directly to the kitchen, which would take way much less time. 

This would mean that the menu list has to be be up to date with what exists in the kitchen stock inventory with every order updating the state appropriately.
 
This is where Elixir processes come in handy (powered by Erlang). What are processes? In a nutshell, it is the execution
of the passive collection of instructions. A process can be in different states, the send, receive and execution. Take
for instance a drawer, you can store items and remove items from the drawer.
 
For our use case, we will use processes to keep the menu state;
Up to date
Maintain state.


Let’s create a module MenuProcess.ex and see how we shall execute the process from the client in the menuserver.
Below is a breakdown of a couple of processes in our module. Our module will enable three processes;
Return the current menu state
Add items to the menu
Handle wrong entries

start_link begins a spawn linked to the current process with the given functions, the pid is registered using `Process.register`. For the client requests to be handled on the server, start_link is called, the function menu_state is spawned to its own process then passed the initial state which in our case will change from an empty [] to an actual list of items to be added to the menu. The function responsible for that is shown below;

 ```
defmodule Menuprocess do
  
  #menu server
  @doc"""
  This function initializes our server 
  """
   @spec start_link(any()) :: pid()
    def start_link(initial_state \\ []) do
     pid = spawn(__MODULE__, :menu_state, [initial_state])
     Process.register(pid, :process)
     pid 
    end
end 
```

Return the current menu state:
To return the current state of the menu, we basically need to send a message from the client requesting for all items
present in our server to our mailbox which is handled by the receive do (whose work is to await requests and match them 
to the messages in the mailbox), then the server responds with the state of the menu.

```
#server

@spec menu_state(tuple()) :: {:ok, list(String.t())}
  def menu_state(state) do
    receive do
      {caller, :items} ->
        send caller, state
        menu_state(state)
    end
  end
  
#from client

@spec all() :: {:ok, list(String.t())}
    def all do 
      send :process, {self(), :items}
        receive do state -> inspect state end
    end
```

Adding a list of items to our menu list is handled by a different function which takes in {self(), :additems, items}
(from the client) the same way we return the menu state is the same way we add items to our menu, the receive do
function takes the message sent then looks up the mailbox and matches it to {caller, :additems, item} which in turn
adds the items to the menu and returns the new_state of the menu.

```
#server

@spec menu_state(tuple()) :: {:ok, list(String.t())}
  def menu_state(state) do
    receive do
     {caller, :additems, item} ->
        new_state = [item | state]
        send caller, length new_state
        menu_state(new_state)
    end
  end
        
#from client

 @spec add_item(String.t()) :: {:ok, list(String.t())}
    def add_item(item)do
      send :process, {self(), :additems, item}
        receive do response -> inspect response end
    end
```

To handle all wrong entries that don’t match any messages in the mailbox, we use the function below.

```
#server
 @spec menu_state(tuple()) :: {:ok, list(String.t())}
  def menu_state(state) do
    receive do
     _error ->
       IO.puts "Wrong entry"
       menu_state(state)
    end
  end
```

Fire up iex and excute the following commands.
```
iex(2)> pid = Menuprocess.start_link()
#PID<0.144.0>
iex(3)> Menuprocess.add_item({"Tea", 100})
"1"
iex(4)> Menuprocess.add_item({"Pancakes", 100})
"2"
iex(5)> Menuprocess.all()
"[{\"Pancakes\", 100}, {\"Tea\", 100}]"
iex(6)> Menuprocess.add_item({"Sausages", 50})
"3"
iex(7)> Menuprocess.all()
"[{\"Sausages\", 50}, {\"Pancakes\", 100}, {\"Tea\", 100}]"
```

Using add_item we are modifying the state and all shows the maintenance of our system state, i.e you can add as many 
items and the length of the state is maintained, which in our case is a list of 3 items so far.

With the steps shown above, the restaurant is able to instantly perform updates and maintain the state of its menu, which the customer will then use to place their orders and eliminate the need of waiting for someone to take your order.
