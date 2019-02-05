**Maintain and update processes**
A few months ago, I walked into a restaurant with a friend to grab a meal. 
The first thing we needed was a menu(to enable us place our orders) which was supposed to be brought by the waiter, 
that process ended up taking over 30 min. As we were was waiting, I noticed some customers walk out without placing 
their orders, their faces displaying disappointment. I wondered how many customers they lost on a daily basis and the 
amount of money they lost on the orders not made because of the inefficiency at the menu provision and order stage.
 
Recently when I was working on Elixir processes, I remembered the restaurant incident and I thought, 
processes can be used to hold state. Therefore, a restaurant menu can always be availed to customers on their table
 (perhaps using a screen on the table), with the new delicacies/meals of the day list. The customers would then be able
to place orders directly to the kitchen, which would take way much less time. This would mean that the menu list has to 
be flawless and everything listed on it should be available and the restaurant would have a way of tracking orders made
against their stock.
 
This is where Elixir processes come in handy (powered by Erlang). What are processes? In a nutshell, it is the execution
of the passive collection of instructions. A process can be in different states, the send, receive and execution. Take
for instance a drawer, you can store items and remove items from the drawer.
 
For our use case, we will use processes to keep the menu state;
Up to date
Maintain state.


Let’s create a module Menuprocess.ex and see how we shall execute the process from the client in the menuserver.
Below is a breakdown of a couple of processes in our module. Our module will enable three processes;
Return the current menu state
Add items to the menu
Handle wrong entries

For the client requests to be handled on the server, start_link is called, the function menu_state is spawned to its own
process then passed the initial state which in our case will change from an empty [] to an actual list of items to be 
added to the menu. The function responsible for that is shown below;

**add code**

Return the current menu state:
To return the current state of the menu, we basically need to send a message from the client requesting for all items
present in our server to our mailbox which is handled by the receive do (whose work is to await requests and match them 
to the messages in the mailbox), then the server responds with the state of the menu.

**add code**

Adding a list of items to our menu list is handled by a different function which takes in {self(), :additems, items}
(from the client) the same way we return the menu state is the same way we add items to our menu, the receive do
function takes the message sent then looks up the mailbox and matches it to {caller, :additems, item} which in turn
adds the items to the menu and returns the new_state of the menu.


**add code**

To handle all wrong entries that don’t match any messages in the mailbox, we use the function below.

**add code**

**add iex code**

Using add_item we are modifying the state and all shows the maintenance of our system state, i.e you can add as many 
items and the length of the state is maintained, which in our case is a list of 3 items so far.

With the steps shown above, the chef can instantly perform updates and maintain the state of the menu, which the customer 
will then use to place their orders and eliminate the need of waiting for someone to take your order.

