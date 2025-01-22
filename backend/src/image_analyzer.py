import cv2
import numpy as np

from PIL import Image

def analyze(image_path):
    try:
        nr_piantine = conta_piantine(image_path)
        return nr_piantine
    except Exception as e:
        raise ValueError(f"Errore durante l'analisi dell'immagine: {e}")


def conta_piantine(image_path):
    img = cv2.imread(image_path)

    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    lower_green = np.array([25, 40, 40])
    upper_green = np.array([90, 255, 255])
    mask = cv2.inRange(hsv, lower_green, upper_green)

    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    min_area = 50
    filtered_contours = [cnt for cnt in contours if cv2.contourArea(cnt) > min_area]

    plant_centers = []
    for cnt in filtered_contours:
        M = cv2.moments(cnt)
        if M["m00"] != 0:
            cX = int(M["m10"] / M["m00"])
            cY = int(M["m01"] / M["m00"])
            plant_centers.append((cX, cY))

    max_distance = 30 
    grouped_plants = []
    used_centers = set()

    for i, center1 in enumerate(plant_centers):
        if i in used_centers:
            continue
        group = [center1]
        for j, center2 in enumerate(plant_centers):
            if i != j and j not in used_centers:
                distance = np.sqrt((center1[0] - center2[0])**2 + (center1[1] - center2[1])**2)
                if distance < max_distance:
                    group.append(center2)
                    used_centers.add(j)
        grouped_plants.append(group)

    num_piantine = len(grouped_plants)

    return num_piantine
