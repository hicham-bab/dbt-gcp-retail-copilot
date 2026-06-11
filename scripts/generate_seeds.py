#!/usr/bin/env python3
"""
Deterministic synthetic data generator for the GreenField Retail demo.

Produces 10 raw CSV seeds with referential integrity so the dbt project
builds end-to-end in BigQuery. Re-running with the same SEED is stable.

Usage:
    python3 scripts/generate_seeds.py
"""
import csv
import os
import random
from datetime import datetime, timedelta, date

SEED = 42
random.seed(SEED)

HERE = os.path.dirname(os.path.abspath(__file__))
SEEDS_DIR = os.path.join(HERE, "..", "seeds")
os.makedirs(SEEDS_DIR, exist_ok=True)

START = date(2024, 1, 1)
END = date(2026, 6, 1)
DAYS = (END - START).days


def rand_date(start=START, end=END):
    return start + timedelta(days=random.randint(0, (end - start).days))


def rand_ts(d=None):
    d = d or rand_date()
    return datetime(d.year, d.month, d.day,
                    random.randint(8, 22), random.randint(0, 59), random.randint(0, 59))


def write(name, header, rows):
    path = os.path.join(SEEDS_DIR, name)
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"  {name:32s} {len(rows):>7d} rows")


# ----------------------------------------------------------------------------
# Reference data
# ----------------------------------------------------------------------------
REGIONS = [
    ("NA", "United States"), ("NA", "Canada"),
    ("EMEA", "United Kingdom"), ("EMEA", "Germany"), ("EMEA", "France"),
    ("APAC", "Australia"), ("APAC", "Japan"),
]
CHANNELS = ["web", "store", "mobile_app"]
PAYMENT_METHODS = ["credit_card", "paypal", "gift_card", "apple_pay"]
UTM_SOURCES = ["google", "google", "google", "meta", "email", "organic", "bing"]
CAMPAIGNS = ["spring_sale", "summer_clearance", "back_to_school",
             "holiday_2024", "holiday_2025", "always_on", "brand_search"]
DEVICES = ["desktop", "mobile", "tablet"]

DEPARTMENTS = {
    "Apparel": ["T-Shirts", "Jeans", "Outerwear", "Footwear", "Accessories"],
    "Home": ["Kitchen", "Bedding", "Decor", "Furniture"],
    "Electronics": ["Audio", "Wearables", "Smart Home"],
    "Outdoor": ["Camping", "Cycling", "Fitness"],
}

# ----------------------------------------------------------------------------
# stores
# ----------------------------------------------------------------------------
stores = []
for sid in range(1, 21):
    region, country = random.choice(REGIONS)
    stores.append([
        sid,
        f"GreenField #{sid:03d}",
        region,
        country,
        rand_date(date(2020, 1, 1), date(2023, 12, 31)).isoformat(),
    ])
write("raw_stores.csv",
      ["store_id", "store_name", "region", "country", "opened_date"], stores)

# ----------------------------------------------------------------------------
# product_categories
# ----------------------------------------------------------------------------
categories = []
cat_id = 1
cat_ids = []
for dept, cats in DEPARTMENTS.items():
    for cname in cats:
        categories.append([cat_id, cname, dept])
        cat_ids.append(cat_id)
        cat_id += 1
write("raw_product_categories.csv",
      ["category_id", "category_name", "department"], categories)

# ----------------------------------------------------------------------------
# products
# ----------------------------------------------------------------------------
ADJ = ["Classic", "Premium", "Eco", "Sport", "Urban", "Vintage", "Pro", "Lite"]
NOUN = ["Tee", "Jacket", "Mug", "Lamp", "Earbuds", "Watch", "Tent", "Bottle",
        "Sneaker", "Pillow", "Chair", "Speaker", "Sensor", "Backpack", "Glove"]
products = []
for pid in range(1, 121):
    category_id = random.choice(cat_ids)
    cost = random.randint(500, 9000)               # cents
    price = int(cost * random.uniform(1.4, 2.8))   # cents
    products.append([
        pid,
        f"{random.choice(ADJ)} {random.choice(NOUN)} {pid:03d}",
        category_id,
        cost,
        price,
        random.random() > 0.08,  # ~8% inactive
    ])
write("raw_products.csv",
      ["product_id", "product_name", "category_id",
       "unit_cost_cents", "unit_price_cents", "is_active"], products)
product_price = {p[0]: p[4] for p in products}
active_products = [p[0] for p in products if p[5]]

# ----------------------------------------------------------------------------
# customers
# ----------------------------------------------------------------------------
FIRST = ["Alex", "Sam", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Jamie",
         "Avery", "Quinn", "Drew", "Reese", "Skyler", "Cameron", "Hayden",
         "Noor", "Yuki", "Liam", "Mia", "Omar", "Ines", "Lars", "Sofia"]
LAST = ["Smith", "Johnson", "Lee", "Garcia", "Mueller", "Dubois", "Tanaka",
        "Brown", "Wilson", "Khan", "Rossi", "Nguyen", "Andersen", "Costa",
        "Schmidt", "Park", "Silva", "Walker", "Ito", "Haddad"]
customers = []
for cid in range(1, 801):
    fn = random.choice(FIRST)
    ln = random.choice(LAST)
    region, country = random.choice(REGIONS)
    signup = rand_date()
    # ~3% messy emails (missing domain) to make data-quality tests meaningful
    email = f"{fn.lower()}.{ln.lower()}{cid}@example.com" if random.random() > 0.03 \
        else f"{fn.lower()}.{ln.lower()}{cid}"
    customers.append([
        cid, fn, ln, email, signup.isoformat(), country, region,
        random.randint(1, 20),
    ])
write("raw_customers.csv",
      ["customer_id", "first_name", "last_name", "email", "signup_date",
       "country", "region", "home_store_id"], customers)
customer_signup = {c[0]: date.fromisoformat(c[4]) for c in customers}

# ----------------------------------------------------------------------------
# orders + order_items + payments
# ----------------------------------------------------------------------------
orders = []
order_items = []
payments = []
oid = 1
oiid = 1
pid_seq = 1
STATUSES = ["completed", "completed", "completed", "completed",
            "returned", "cancelled", "pending"]

for cid in range(1, 801):
    n_orders = random.choices([0, 1, 2, 3, 5, 8], weights=[8, 30, 28, 18, 10, 6])[0]
    signup = customer_signup[cid]
    for _ in range(n_orders):
        order_date = rand_date(max(signup, START), END)
        status = random.choice(STATUSES)
        channel = random.choice(CHANNELS)
        store_id = random.randint(1, 20)
        ots = rand_ts(order_date)
        n_items = random.randint(1, 5)
        order_total = 0
        for _ in range(n_items):
            prod = random.choice(active_products)
            qty = random.randint(1, 4)
            unit_price = product_price[prod]
            # occasional discount
            discount = int(unit_price * qty * random.choice([0, 0, 0, 0.1, 0.2])) \
                if random.random() > 0.7 else 0
            order_items.append([oiid, oid, prod, qty, unit_price, discount])
            order_total += unit_price * qty - discount
            oiid += 1
        orders.append([oid, cid, store_id, ots.isoformat(), status, channel])
        # payment (skip for cancelled/pending sometimes)
        if status not in ("cancelled",) and random.random() > 0.05:
            pay_ts = ots + timedelta(minutes=random.randint(1, 30))
            payments.append([
                pid_seq, oid, random.choice(PAYMENT_METHODS),
                order_total, pay_ts.isoformat(),
                "captured" if status != "returned" else "refunded",
            ])
            pid_seq += 1
        oid += 1

write("raw_orders.csv",
      ["order_id", "customer_id", "store_id", "order_ts", "status", "channel"], orders)
write("raw_order_items.csv",
      ["order_item_id", "order_id", "product_id", "quantity",
       "unit_price_cents", "discount_cents"], order_items)
write("raw_payments.csv",
      ["payment_id", "order_id", "payment_method", "amount_cents",
       "payment_ts", "status"], payments)

# ----------------------------------------------------------------------------
# inventory_snapshots (monthly snapshot per store x sampled products)
# ----------------------------------------------------------------------------
inventory = []
snap = date(2025, 1, 1)
while snap <= END:
    for store_id in range(1, 21):
        for prod in random.sample(active_products, 25):
            on_hand = random.randint(0, 300)
            reserved = random.randint(0, min(on_hand, 40))
            inventory.append([snap.isoformat(), store_id, prod, on_hand, reserved])
    # advance ~1 month
    month = snap.month + 1
    year = snap.year + (month > 12)
    month = month - 12 if month > 12 else month
    snap = date(year, month, 1)
write("raw_inventory_snapshots.csv",
      ["snapshot_date", "store_id", "product_id", "units_on_hand", "units_reserved"],
      inventory)

# ----------------------------------------------------------------------------
# web_sessions
# ----------------------------------------------------------------------------
sessions = []
for sidx in range(1, 6001):
    start = rand_ts()
    dur = random.randint(20, 2400)
    end = start + timedelta(seconds=dur)
    has_customer = random.random() > 0.45
    sessions.append([
        f"sess_{sidx:06d}",
        random.randint(1, 800) if has_customer else "",
        start.isoformat(),
        end.isoformat(),
        random.choice(["web", "mobile_app"]),
        random.choice(["/home", "/category", "/product", "/cart", "/promo"]),
        random.choice(DEVICES),
        random.choice(UTM_SOURCES),
        random.choice(CAMPAIGNS),
    ])
write("raw_web_sessions.csv",
      ["session_id", "customer_id", "session_start_ts", "session_end_ts",
       "channel", "landing_page", "device", "utm_source", "utm_campaign"], sessions)

# ----------------------------------------------------------------------------
# marketing_spend (daily per channel x campaign)
# ----------------------------------------------------------------------------
spend = []
d = START
while d <= END:
    for src in set(UTM_SOURCES):
        if src == "organic":
            continue
        if random.random() > 0.6:
            continue
        campaign = random.choice(CAMPAIGNS)
        spend_cents = random.randint(5000, 500000)
        impressions = spend_cents // random.randint(2, 8)
        clicks = int(impressions * random.uniform(0.005, 0.05))
        spend.append([d.isoformat(), src, campaign, src, campaign,
                      spend_cents, impressions, clicks])
    d += timedelta(days=1)
write("raw_marketing_spend.csv",
      ["spend_date", "channel", "campaign", "utm_source", "utm_campaign",
       "spend_cents", "impressions", "clicks"], spend)

print("\nDone. Seeds written to seeds/")
