import time,requests
from flask import Flask, flash, redirect, render_template, request, session
from datetime import timedelta
import firebase_admin
from firebase_admin import credentials, firestore, auth
import requests
import pyrebase as pyb

cred = credentials.Certificate("firebase_config.json")
firebase_admin.initialize_app(cred)
firestore_db = firestore.client()

#pyrebase
config = {
  "apiKey": "AIzaSyCKiGJOHzXhHkb4Kfg41rQXJoo9JOmee3M",
  "authDomain": "navindia-6cc54.firebaseapp.com",
  "databaseURL": "hungerhaven-27983.firebaseapp.com",
  "storageBucket": "navindia-6cc54.appspot.com",
  "credentials": 'firebase_config.json'
}
firebase = pyb.initialize_app(config=config)

# Flask App Initialize
app = Flask(__name__)
app.secret_key = "bdsvjdv32543ub345"
app.config["TEMPLATES_AUTO_RELOAD"] = True
app.config['SESSION_REFRESH_EACH_REQUEST'] = True
app.permanent_session_lifetime = timedelta(hours=8)

@app.after_request
def after_request(response):
    """Ensure responses aren't cached"""
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response


@app.route("/sess", methods=["GET", "POST"])
def sess():
    print(session.get('is_login'), session.get("email"),  session.get("name"), session.get("phone"))
    return "Check Print Statment"


@app.route("/", methods=["GET", "POST"])
def home():
    total_potholes=0
    total_potholes_verified=0
    total_potholes_unverified=0      
    try:
        potholes_ref = firestore_db.collection('pothole_details')
        potholes_docs = potholes_ref.get()
        total_potholes = len(potholes_docs)
        for doc in potholes_docs:
            if doc.get('status') == 'verified':
                total_potholes_verified += 1
        total_potholes_unverified = total_potholes-total_potholes_verified
    except Exception as e:
        print("Exception in data fetch", e)
    return render_template("index.html", total_potholes=total_potholes, total_potholes_verified=total_potholes_verified, total_potholes_unverified=total_potholes_unverified)

    


# Shops Downside
@app.route("/all_potholes", methods=['POST', 'GET'])
def all_potholes():
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")
    
    try:
        # Initialize an empty list to store fullnames
        fullnames = []
        latitudes = []
        longitudes = []
        addresses = []
        road_qualities = []
        statuses = []
        pothole_doc_id = []

        # Query the 'pothole_details' collection
        potholes_ref = firestore_db.collection('pothole_details')
        potholes_docs = potholes_ref.get()
        
        for pothole_doc in potholes_docs:
            # Extract 'userId' from each document
            pothole_doc_id.append(pothole_doc.id)
            user_id = pothole_doc.get('userId')

            # Use 'userId' as document ID to fetch corresponding document from 'user_details' collection
            user_doc_ref = firestore_db.collection('user_details').document(user_id)
            user_doc = user_doc_ref.get()

            # Extract 'fullname' from 'user_details' document and append to the list
            if user_doc.exists:
                fullname = user_doc.get('fullname')
                fullnames.append(fullname)

                # Extract other fields from 'pothole_details' document and append to respective lists
            latitude = pothole_doc.get('latitude')
            latitudes.append(latitude)

            longitude = pothole_doc.get('longitude')
            longitudes.append(longitude)

            address = pothole_doc.get('address')
            addresses.append(address)

            road_quality = pothole_doc.get('roadQuality')
            road_qualities.append(road_quality)

            status = pothole_doc.get('status')
            statuses.append(status)

    except Exception as e:
        print("Exception in data fetch", e)
        # Handle exceptions as per your requirement
    data = {'pothole_details': [{
        "Id": pothole_doc_id,
        'Username': fullnames,
        'Latitude': latitudes,
        'Longitude': longitudes,
        'Address': addresses,
        'RoadQuality': road_qualities,
        'Status': statuses
    }]}
    
    # Initialize an empty list to store the transformed data
    transformed_data = []

    # Iterate over the list of dictionaries inside 'pothole_details'
    for pothole in data['pothole_details']:
        for i in range(len(pothole['Username'])):
            # Create a dictionary for each pothole entry
            entry = {
                "Id": pothole['Id'][i],
                "Username": pothole['Username'][i],
                "Latitude": pothole['Latitude'][i],
                "Longitude": pothole['Longitude'][i],
                "Address": pothole['Address'][i],
                "RoadQuality": pothole['RoadQuality'][i],
                "Status": pothole['Status'][i]
            }
            # Append the entry to the transformed data list
            transformed_data.append(entry)


    return render_template("all_pothole.html", data=transformed_data)


@app.route("/not_approved_pothole", methods=['POST', 'GET'])
def all_not_approved_pothole():
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")

    try:
        # Initialize an empty list to store fullnames
        fullnames = []
        latitudes = []
        longitudes = []
        addresses = []
        road_qualities = []
        statuses = []
        pothole_doc_id = []

        # Query the 'pothole_details' collection
        potholes_ref = firestore_db.collection('pothole_details')
        query = potholes_ref.where('status', '!=', 'verified')
        potholes_docs = query.get()
        
        for pothole_doc in potholes_docs:
            # Extract 'userId' from each document
            pothole_doc_id.append(pothole_doc.id)
            user_id = pothole_doc.get('userId')

            # Use 'userId' as document ID to fetch corresponding document from 'user_details' collection
            user_doc_ref = firestore_db.collection('user_details').document(user_id)
            user_doc = user_doc_ref.get()

            # Extract 'fullname' from 'user_details' document and append to the list
            if user_doc.exists:
                fullname = user_doc.get('fullname')
                fullnames.append(fullname)

                # Extract other fields from 'pothole_details' document and append to respective lists
            latitude = pothole_doc.get('latitude')
            latitudes.append(latitude)

            longitude = pothole_doc.get('longitude')
            longitudes.append(longitude)

            address = pothole_doc.get('address')
            addresses.append(address)

            road_quality = pothole_doc.get('roadQuality')
            road_qualities.append(road_quality)

            status = pothole_doc.get('status')
            statuses.append(status)

    except Exception as e:
        print("Exception in data fetch", e)
        # Handle exceptions as per your requirement
    data = {'pothole_details': [{
        "Id": pothole_doc_id,
        'Username': fullnames,
        'Latitude': latitudes,
        'Longitude': longitudes,
        'Address': addresses,
        'RoadQuality': road_qualities,
        'Status': statuses
    }]}
    
    # Initialize an empty list to store the transformed data
    transformed_data = []

    # Iterate over the list of dictionaries inside 'pothole_details'
    for pothole in data['pothole_details']:
        for i in range(len(pothole['Username'])):
            # Create a dictionary for each pothole entry
            entry = {
                "Id": pothole['Id'][i],
                "Username": pothole['Username'][i],
                "Latitude": pothole['Latitude'][i],
                "Longitude": pothole['Longitude'][i],
                "Address": pothole['Address'][i],
                "RoadQuality": pothole['RoadQuality'][i],
                "Status": pothole['Status'][i]
            }
            # Append the entry to the transformed data list
            transformed_data.append(entry)

    return render_template("approval_wait_pothole.html", data=transformed_data)


@app.route("/approved_pothole", methods=['POST', 'GET'])
def all_approved_pothole():
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")
    
    try:
        # Initialize an empty list to store fullnames
        fullnames = []
        latitudes = []
        longitudes = []
        addresses = []
        road_qualities = []
        statuses = []
        pothole_doc_id = []

        # Query the 'pothole_details' collection
        potholes_ref = firestore_db.collection('pothole_details')
        query = potholes_ref.where('status', '==', 'verified')
        potholes_docs = query.get()
        
        for pothole_doc in potholes_docs:
            # Extract 'userId' from each document
            pothole_doc_id.append(pothole_doc.id)
            user_id = pothole_doc.get('userId')

            # Use 'userId' as document ID to fetch corresponding document from 'user_details' collection
            user_doc_ref = firestore_db.collection('user_details').document(user_id)
            user_doc = user_doc_ref.get()

            # Extract 'fullname' from 'user_details' document and append to the list
            if user_doc.exists:
                fullname = user_doc.get('fullname')
                fullnames.append(fullname)

                # Extract other fields from 'pothole_details' document and append to respective lists
            latitude = pothole_doc.get('latitude')
            latitudes.append(latitude)

            longitude = pothole_doc.get('longitude')
            longitudes.append(longitude)

            address = pothole_doc.get('address')
            addresses.append(address)

            road_quality = pothole_doc.get('roadQuality')
            road_qualities.append(road_quality)

            status = pothole_doc.get('status')
            statuses.append(status)

    except Exception as e:
        print("Exception in data fetch", e)
        # Handle exceptions as per your requirement
    data = {'pothole_details': [{
        "Id": pothole_doc_id,
        'Username': fullnames,
        'Latitude': latitudes,
        'Longitude': longitudes,
        'Address': addresses,
        'RoadQuality': road_qualities,
        'Status': statuses
    }]}
    
    # Initialize an empty list to store the transformed data
    transformed_data = []

    # Iterate over the list of dictionaries inside 'pothole_details'
    for pothole in data['pothole_details']:
        for i in range(len(pothole['Username'])):
            # Create a dictionary for each pothole entry
            entry = {
                "Id": pothole['Id'][i],
                "Username": pothole['Username'][i],
                "Latitude": pothole['Latitude'][i],
                "Longitude": pothole['Longitude'][i],
                "Address": pothole['Address'][i],
                "RoadQuality": pothole['RoadQuality'][i],
                "Status": pothole['Status'][i]
            }
            # Append the entry to the transformed data list
            transformed_data.append(entry)

    return render_template("approved_pothole.html", data=transformed_data)



@app.route("/pothole/<string:id>", methods=['POST', 'GET'])
def particular_shop(id):
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")
    try:
        potholes_ref = firestore_db.collection('pothole_details').document(id)
        pothole_doc = potholes_ref.get()
        if pothole_doc.exists:
            pothole_data = pothole_doc.to_dict()
            pothole_data['id'] = id
            return render_template("particular_pothole_details.html", data=pothole_data)
        
    except Exception as e:
        print("Exception in data fetch", e)

    return render_template("particular_pothole_details.html")


@app.route("/approve_pothole", methods=["POST","GET"])
def approve_pothole():
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")
    if request.method == "POST":
        pothole_id = request.form.get("id")
        pothole_ref = firestore_db.collection('pothole_details').document(pothole_id)
        pothole_ref.update({'status': 'verified'})
        pothole_ref.set({'AMC_status': 'completed'}, merge=True)
        return redirect("/all_potholes")
    

@app.route("/home", methods=['POST', 'GET'])
def homepage():
    if not session.get("is_login"):
        flash("Please Login First","danger") 
        return redirect("/login")
    else:
        total_potholes=0
        total_potholes_verified=0
        total_potholes_unverified=0      
        try:
            potholes_ref = firestore_db.collection('pothole_details')
            potholes_docs = potholes_ref.get()
            total_potholes = len(potholes_docs)
            for doc in potholes_docs:
                if doc.get('status') == 'verified':
                    total_potholes_verified += 1
            total_potholes_unverified = total_potholes-total_potholes_verified
        except Exception as e:
            print("Exception in data fetch", e)
        return render_template("index.html", total_potholes=total_potholes, total_potholes_verified=total_potholes_verified, total_potholes_unverified=total_potholes_unverified)
    

if __name__ == "__main__":
    app.run(debug=True)
