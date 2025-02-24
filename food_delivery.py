import streamlit as st
import mysql.connector
import google.generativeai as genai
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Securely retrieve credentials from environment variables
DB_HOST = "host"
DB_USER = "USER"
DB_PASSWORD = "PASSWORD"
DB_NAME = "DATABASE_NAMR"
GEMINI_API_KEY = "YOUR_API_KEY"

genai.configure(api_key=GEMINI_API_KEY)

def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

def get_restaurants():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM restaurants")
    data = cursor.fetchall()
    conn.close()
    return data

def get_menu(restaurant_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM menu WHERE restaurant_id = %s", (restaurant_id,))
    data = cursor.fetchall()
    conn.close()
    return data

def place_order(user_id, restaurant_id, menu_item_id, price):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO orders (user_id, restaurant_id, menu_item_id, price, status) VALUES (%s, %s, %s, %s, %s)",
        (user_id, restaurant_id, menu_item_id, price, "Pending")
    )
    conn.commit()
    order_id = cursor.lastrowid
    conn.close()
    return order_id

def process_payment(order_id, user_id, amount, payment_method):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO payments (order_id, user_id, amount, payment_method, payment_status) VALUES (%s, %s, %s, %s, %s)",
        (order_id, user_id, amount, payment_method, "Completed")
    )
    conn.commit()
    conn.close()

def generate_bill(order_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT orders.id, menu.name, menu.price FROM orders JOIN menu ON orders.menu_item_id = menu.id WHERE orders.id = %s", (order_id,))
    order_details = cursor.fetchone()
    conn.close()
    return order_details

def submit_review(user_id, restaurant_id, rating, review_text):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO reviews (user_id, restaurant_id, rating, review_text) VALUES (%s, %s, %s, %s)",
        (user_id, restaurant_id, rating, review_text)
    )
    conn.commit()
    conn.close()

def get_reviews(restaurant_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT rating, review_text FROM reviews WHERE restaurant_id = %s", (restaurant_id,))
    reviews = cursor.fetchall()
    conn.close()
    return reviews

st.set_page_config(page_title="Food Delivery System", page_icon="🍔", layout="wide", initial_sidebar_state="collapsed")
st.markdown("<style>body {background-color: #f5f5f5;}</style>", unsafe_allow_html=True)

st.title("🍕 Food Delivery System")

if "page" not in st.session_state:
    st.session_state.page = "Restaurants"

if st.session_state.page == "Restaurants":
    st.title("🏬 Restaurants")
    restaurants = get_restaurants()
    for restaurant in restaurants:
        if st.button(f"🍽️ {restaurant['name']} ({restaurant['location']})"):
            st.session_state.selected_restaurant = restaurant["id"]
            st.session_state.page = "Menu"
            st.rerun()

elif st.session_state.page == "Menu":
    st.title("📜 Menu")
    menu_items = get_menu(st.session_state.selected_restaurant)
    for item in menu_items:
        if st.button(f"🛒 Order {item['name']} - ₹{item['price']}"):
            st.session_state.selected_item = item
            st.session_state.page = "Order"
            st.rerun()

elif st.session_state.page == "Order":
    st.title("✅ Order Confirmation")
    order_id = place_order(1, st.session_state.selected_restaurant, st.session_state.selected_item["id"], st.session_state.selected_item["price"])
    st.session_state.order_id = order_id
    st.session_state.page = "Payment"
    st.success("🛍️ Order Placed Successfully!")
    st.rerun()

elif st.session_state.page == "Payment":
    st.title("💳 Payment")
    payment_method = st.radio("Select Payment Method", ["Credit Card", "Debit Card", "UPI", "Cash on Delivery"])
    if st.button("💰 Pay Now"):
        process_payment(st.session_state.order_id, 1, st.session_state.selected_item["price"], payment_method)
        st.session_state.page = "Reviews"
        st.success("✅ Payment Successful!")
        st.rerun()

elif st.session_state.page == "Reviews":
    st.title("🌟 Customer Reviews")
    reviews = get_reviews(st.session_state.selected_restaurant)
    for review in reviews:
        st.markdown(f"**⭐ {review['rating']}/5** - {review['review_text']}")
    
    st.subheader("📝 Write a Review")
    rating = st.slider("Rate the restaurant (1-5) ⭐", 1, 5, 3)
    review_text = st.text_area("Your Review")
    if st.button("📨 Submit Review"):
        submit_review(1, st.session_state.selected_restaurant, rating, review_text)
        st.success("✅ Review Submitted Successfully!")
