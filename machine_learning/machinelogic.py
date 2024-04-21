import cv2
import os
import firebase_admin
from firebase_admin import credentials, firestore
import requests
import tempfile
cred = credentials.Certificate("firebase_config.json")
firebase_admin.initialize_app(cred)
firestore_db = firestore.client()


def fetch_image_paths():
    pothole_details_ref = firestore_db.collection('pothole_details')
    pothole_details_docs = pothole_details_ref.stream()
    image_paths = []
    for doc in pothole_details_docs:
        data = doc.to_dict()
        doc_id = doc.id
        image_path = data.get('imagePath')
        user_id = data.get('userId')
        print(user_id)
        image_paths.append({'document_id': doc_id, 'image_path': image_path, 'user_id': user_id})
    return image_paths
def detect_potholes(image_path):
    img = cv2.imread(image_path)
    if img is None:
        print(f"Failed to read image from path: {image_path}")
        return False, 0.0
    with open(('obj.names'),'r') as f:
        classes = f.read().splitlines()
    net = cv2.dnn.readNet('yolov4_tiny.weights', 'yolov4_tiny.cfg')
    model = cv2.dnn_DetectionModel(net)
    model.setInputParams(scale=1 / 255, size=(416, 416), swapRB=True)
    classIds, scores, boxes = model.detect(img, confThreshold=0.6, nmsThreshold=0.4)
    if len(classIds) > 0:
        status = 'verified' if scores[0] > 0.6 else 'cancel'
        return True, scores[0], status
    else:
        return False, 0.0, 'no_potholes'
image_paths = fetch_image_paths()
for item in image_paths:
    document_id = item['document_id']
    image_path = item['image_path']
    user_id = item['user_id']
    print(f"Downloading and processing image with document ID: {document_id}")
    response = requests.get(image_path)
    if response.status_code == 200:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_image_file:
            temp_image_file.write(response.content)
            temp_image_path = temp_image_file.name
        detected, score, status = detect_potholes(temp_image_path)
        firestore_db.collection('pothole_details').document(document_id).update({'status': status})
        if status == 'verified':
            user_ref = firestore_db.collection('user_details').document(user_id)
            user = user_ref.get()
            if user.exists:
                user_data = user.to_dict()
                current_points = user_data.get('points', 0)
                user_ref.update({'points': current_points + 1})
        os.remove(temp_image_path)
        print(f"Status updated to: {status}")
    else:
        print(f"Failed to download image from URL: {image_path}")