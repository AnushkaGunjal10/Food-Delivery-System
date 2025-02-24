import streamlit as st
import mysql.connector

# Connect to MySQL database
def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Welcome@2020",
            database="KHAYALI_PULAW"
        )
        return conn
    except mysql.connector.Error as err:
        st.error(f"Database Connection Error: {err}")
        return None

# Function to fetch data from the database
def fetch_data(query):
    conn = get_db_connection()
    if conn is None:
        return []
    
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute(query)
        data = cursor.fetchall()
    except mysql.connector.Error as err:
        st.error(f"Error fetching data: {err}")
        data = []
    
    cursor.close()
    conn.close()
    return data

# Function to create a new user account
def create_user(name, email, phone, address, password):
    if not name or not email or not phone or not address or not password:
        st.warning("⚠️ Please fill in all fields.")
        return

    conn = get_db_connection()
    if conn is None:
        return

    cursor = conn.cursor()
    try:
        query = "INSERT INTO Users (name, email, phone, address, password) VALUES (%s, %s, %s, %s, %s)"
        values = (name, email, phone, address, password)
        cursor.execute(query, values)  # Use parameterized queries to avoid syntax errors

        conn.commit()
        st.success("✅ User account created successfully!")
    except mysql.connector.Error as err:
        st.error(f"Error: {err}")
    finally:
        cursor.close()
        conn.close()


# Function to place an order
def place_order(user_id, restaurant_id, menu_id, quantity):
    conn = get_db_connection()
    if conn is None:
        return
    
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT price FROM Menu WHERE menu_id = %s", (menu_id,))
        price_data = cursor.fetchone()
        
        if not price_data:
            st.error("⚠️ Invalid menu item selected.")
            return
        
        price = price_data[0]
        total_amount = price * quantity

        # Insert into Orders table
        cursor.execute(
            "INSERT INTO Orders (user_id, restaurant_id, total_amount) VALUES (%s, %s, %s)",
            (user_id, restaurant_id, total_amount),
        )
        order_id = cursor.lastrowid

        # Insert into OrderDetails table
        cursor.execute(
            "INSERT INTO OrderDetails (order_id, menu_id, quantity, price) VALUES (%s, %s, %s, %s)",
            (order_id, menu_id, quantity, price),
        )

        conn.commit()
        st.success("✅ Order placed successfully!")
    except mysql.connector.Error as err:
        st.error(f"Error: {err}")
    finally:
        cursor.close()
        conn.close()

# Streamlit UI
st.title("🍔 Khayali Pulaw - Food Ordering App")

menu = ["Home", "Restaurants", "Menu", "Orders", "Place Order", "Create Account"]
choice = st.sidebar.selectbox("📌 Select an option", menu)

# Display Restaurants
if choice == "Restaurants":
    st.subheader("🏪 Available Restaurants")
    restaurants = fetch_data("SELECT * FROM Restaurants")
    if not restaurants:
        st.info("No restaurants available.")
    else:
        for restaurant in restaurants:
            st.write(f"📍 **{restaurant['name']}** - {restaurant['address']} ({restaurant['cuisine_type']})")
            st.write(f"⭐ Rating: {restaurant['rating']} | 📞 {restaurant['phone']}")
            st.write("---")

# Display Menu
elif choice == "Menu":
    st.subheader("🍽️ Food Menu")
    menus = fetch_data(
        "SELECT Menu.item_name, Menu.price, Menu.category, Restaurants.name AS restaurant FROM Menu JOIN Restaurants ON Menu.restaurant_id = Restaurants.restaurant_id"
    )
    if not menus:
        st.info("No menu items available.")
    else:
        for item in menus:
            st.write(f"🍕 **{item['item_name']}** - ₹{item['price']} ({item['category']})")
            st.write(f"🏠 From: {item['restaurant']}")
            st.write("---")

# Display Orders
elif choice == "Orders":
    st.subheader("📦 Recent Orders")
    orders = fetch_data(
        "SELECT Orders.order_id, Users.name AS user, Restaurants.name AS restaurant, Orders.total_amount, Orders.status FROM Orders JOIN Users ON Orders.user_id = Users.user_id JOIN Restaurants ON Orders.restaurant_id = Restaurants.restaurant_id"
    )
    if not orders:
        st.info("No orders found.")
    else:
        for order in orders:
            st.write(f"🆔 **Order ID:** {order['order_id']} | 👤 **{order['user']}** | 🏠 **{order['restaurant']}**")
            st.write(f"💰 **Total:** ₹{order['total_amount']} | 🚀 **Status:** {order['status']}")
            st.write("---")

# Place Order
elif choice == "Place Order":
    st.subheader("🛒 Place an Order")
    
    users = fetch_data("SELECT user_id, name FROM Users")
    if not users:
        st.warning("⚠️ No users found. Please create an account first.")
    else:
        user_choice = st.selectbox("👤 Select User", [(u["user_id"], u["name"]) for u in users], format_func=lambda x: x[1])

        restaurants = fetch_data("SELECT restaurant_id, name FROM Restaurants")
        if not restaurants:
            st.warning("⚠️ No restaurants found.")
        else:
            restaurant_choice = st.selectbox("🏪 Select Restaurant", [(r["restaurant_id"], r["name"]) for r in restaurants], format_func=lambda x: x[1])

            menu_items = fetch_data(f"SELECT menu_id, item_name FROM Menu WHERE restaurant_id = {restaurant_choice[0]}")
            if not menu_items:
                st.warning("⚠️ No menu items found for this restaurant.")
            else:
                menu_choice = st.selectbox("🍽 Select Menu Item", [(m["menu_id"], m["item_name"]) for m in menu_items], format_func=lambda x: x[1])
                quantity = st.number_input("📊 Enter Quantity", min_value=1, value=1)

                if st.button("🚀 Order Now"):
                    place_order(user_choice[0], restaurant_choice[0], menu_choice[0], quantity)

# Create a new user account
elif choice == "Create Account":
    st.subheader("🆕 Create a New Account")
    name = st.text_input("📛 Full Name")
    email = st.text_input("📧 Email")  
    phone = st.text_input("📞 Phone Number")
    address = st.text_area("📍 Address")
    password = st.text_input("🔒 Password", type="password")  # Ensure passwords are hidden

    if st.button("✅ Create Account"):
        create_user(name, email, phone, address, password)

st.sidebar.text("📍 Developed by Anushka Gunjal")
