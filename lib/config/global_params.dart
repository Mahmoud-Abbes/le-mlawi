class GlobalParams {
  static List<Map<String, dynamic>> products = [
    {
      "id": 1,
      "name": "Mlawi chawerma",
      "price": 8.500,
      "description": "Viande - Pomme de terre - Mozzarella",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F97039f0bc5fb9ddb39188331044afe18b87ec547Rectangle%2028.png?alt=media&token=f01c148c-26ba-4af1-8628-fbafa5faf5ea",
      "rating": 4.4,
      "deliveryTime": "25 min",
      "deliveryFee": "Gratuit",
      "category": "Mlawi",
      "supplements": [
        {"name": "Fromage gruyère", "price": 5.000},
        {"name": "Omlette", "price": 1.000},
        {"name": "Double pate", "price": 1.500},
        {"name": "Frite", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 2,
      "name": "Mlawi Poulet",
      "price": 8.000,
      "description": "Poitrine de poulet - Fromage - oignon grillé",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2Ffb24302b319ce782c4667aa58b98d40fb6add34aRectangle%2028.png?alt=media&token=291738b0-e68a-415c-a1a1-f40961350e11",
      "rating": 3.8,
      "deliveryTime": "15 min",
      "deliveryFee": "Gratuit",
      "category": "Mlawi",
      "supplements": [
        {"name": "Fromage gruyère", "price": 5.000},
        {"name": "Omlette", "price": 1.000},
        {"name": "Double pate", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 3,
      "name": "Mlawi Thon",
      "price": 7.000,
      "description": "Thon - Fromage - Oeuf",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F0a6cc9c1112e5460242b43cb4490bf4584542aceRectangle%2028.png?alt=media&token=ca05822d-8091-4004-8cc4-10a096e72f63",
      "rating": 4.9,
      "deliveryTime": "35 min",
      "deliveryFee": "Gratuit",
      "category": "Mlawi",
      "supplements": [
        {"name": "Fromage gruyère", "price": 5.000},
        {"name": "Omlette", "price": 1.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 4,
      "name": "Mlawi Rosbif (Spécial)",
      "price": 10.000,
      "description": "Viande - Pomme de terre - Mozzarella",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F44d17e59cb2e5f91ef936c5a09b853fc1ca06b55Rectangle%2028.png?alt=media&token=20ce2539-ea03-4300-9ef3-2d51b14ad7cd",
      "rating": 4.4,
      "deliveryTime": "25 min",
      "deliveryFee": "Gratuit",
      "category": "Mlawi",
      "supplements": [
        {"name": "Fromage gruyère", "price": 5.000},
        {"name": "Omlette", "price": 1.000},
        {"name": "Double pate", "price": 1.500},
        {"name": "Frite", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },

    // ------------------------------------------------------
    //                     BURGERS (4)
    // ------------------------------------------------------
    {
      "id": 101,
      "name": "Burger Classic",
      "price": 12.000,
      "description": "Viande hachée – Fromage – Tomate – Sauce spéciale",
      "image": "https://ik.imagekit.io/8ble1ymwbp/BurgerClassic.png",
      "rating": 4.5,
      "deliveryTime": "20 min",
      "deliveryFee": "Gratuit",
      "category": "Burger",
      "supplements": [
        {"name": "Fromage cheddar", "price": 3.000},
        {"name": "Bacon", "price": 4.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 102,
      "name": "Chicken Burger",
      "price": 11.000,
      "description": "Poulet pané – Laitue – Mayonnaise",
      "image": "https://ik.imagekit.io/8ble1ymwbp/ChickenBurger.png",
      "rating": 4.1,
      "deliveryTime": "18 min",
      "deliveryFee": "Gratuit",
      "category": "Burger",
      "supplements": [
        {"name": "Fromage cheddar", "price": 3.000},
        {"name": "Oeuf", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 103,
      "name": "Double Cheese Burger",
      "price": 14.000,
      "description": "Double viande – Double cheddar – Sauce BBQ",
      "image": "https://ik.imagekit.io/8ble1ymwbp/DoubleCheeseBurger.png",
      "rating": 4.7,
      "deliveryTime": "22 min",
      "deliveryFee": "Gratuit",
      "category": "Burger",
      "supplements": [
        {"name": "Extra viande", "price": 5.000},
        {"name": "Fromage cheddar", "price": 3.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 104,
      "name": "Spicy Beef Burger",
      "price": 13.500,
      "description": "Viande épicée – Jalapenos – Fromage – Sauce piquante",
      "image": "https://ik.imagekit.io/8ble1ymwbp/Spicy%20Beef%20Burger.png",
      "rating": 4.2,
      "deliveryTime": "19 min",
      "deliveryFee": "Gratuit",
      "category": "Burger",
      "supplements": [
        {"name": "Sauce piquante", "price": 1.000},
        {"name": "Fromage cheddar", "price": 3.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },

    // ------------------------------------------------------
    //                     PIZZAS (4)
    // ------------------------------------------------------
    {
      "id": 201,
      "name": "Pizza Margherita",
      "price": 14.000,
      "description": "Sauce tomate – Mozzarella – Basilic",
      "image": "https://ik.imagekit.io/8ble1ymwbp/PizzaMargherita.png?updatedAt=1764535651467",
      "rating": 4.7,
      "deliveryTime": "30 min",
      "deliveryFee": "Gratuit",
      "category": "Pizza",
      "supplements": [
        {"name": "Fromage supplémentaire", "price": 3.000},
        {"name": "Olives", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 202,
      "name": "Pizza Pepperoni",
      "price": 16.000,
      "description": "Mozzarella – Pepperoni – Sauce tomate",
      "image": "https://ik.imagekit.io/8ble1ymwbp/PizzaPepperoni.png",
      "rating": 4.8,
      "deliveryTime": "28 min",
      "deliveryFee": "Gratuit",
      "category": "Pizza",
      "supplements": [
        {"name": "Fromage supplémentaire", "price": 3.000},
        {"name": "Champignons", "price": 2.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 203,
      "name": "Pizza 4 Fromages",
      "price": 17.000,
      "description": "Mozzarella – Parmesan – Emmental – Bleu",
      "image": "https://ik.imagekit.io/8ble1ymwbp/Pizza4Fromages.png",
      "rating": 4.6,
      "deliveryTime": "32 min",
      "deliveryFee": "Gratuit",
      "category": "Pizza",
      "supplements": [
        {"name": "Olives", "price": 1.500},
        {"name": "Pâte épaisse", "price": 2.000}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    },
    {
      "id": 204,
      "name": "Pizza Thon",
      "price": 15.000,
      "description": "Thon – Mozzarella – Oignon – Sauce tomate",
      "image": "https://ik.imagekit.io/8ble1ymwbp/PizzaThon.png",
      "rating": 4.3,
      "deliveryTime": "27 min",
      "deliveryFee": "Gratuit",
      "category": "Pizza",
      "supplements": [
        {"name": "Fromage supplémentaire", "price": 3.000},
        {"name": "Oeuf", "price": 1.500}
      ],
      "drinks": [
        {"name": "Boisson à 2,500 DT", "price": 2.500}
      ]
    }
  ];



  static List<Map<String, dynamic>> beverages = [
    {
      "name": "Franchina",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F50a47b90c891665cc983ca418d5c4f8e4ba7a555e41ed23a-02f5-400c-b9b6-46a30b8ffe3b-removebg-preview%201.png?alt=media&token=0851ecac-6f1d-4e90-ba3a-453b2ce37722"
    },
    {
      "name": "Mockup",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F39e0a62d88c45ac2fb0625b0fc77e4ad56f3e5d94da7fac5-28fc-46c2-aeeb-a645dc5a9c25-removebg-preview%201.png?alt=media&token=fe2846d3-4eb6-40b4-b26b-3f4b89885ced"
    },
    {
      "name": "Eight",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F1925c3032e1c59271adbd5b00f7ad6bc87a2d67aimage%2019.png?alt=media&token=05c6cabf-8330-4203-a38b-bb950a2051d7"
    }
  ];

  static List<Map<String, dynamic>> categories = [
    {
      "name": "Mlawi",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F421baf8431b259c34b6f89d1fa9db05a271bcabcRectangle%2055.png?alt=media&token=0c357d5b-4d70-4f34-b402-f6125d6f3932"
    },
    {
      "name": "Burger",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F800c497ff54edefee3d7ed2fc4759d5973399f1aRectangle%2056.png?alt=media&token=90f162a4-4790-4b60-a71d-d5b7bd12971e"
    },
    {
      "name": "Pizza",
      "image": "https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2F0SDsGf5XcaCC7VBLawIP%2F552860eff81c6ab5ce6fc19b72204d4e4f63cc77Rectangle%2057.png?alt=media&token=5ea28383-a22a-4143-9b54-6f806fd271f4"
    }
  ];

  static String searchIcon = "https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2F475c9837-71c4-4e92-9a81-e9aadc3560a1.png";

  static String notificationIcon = "https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SDsGf5XcaCC7VBLawIP%2Fa64ba530-cc37-479a-9c58-3fd59661c311.png";

  // Helper method to get product by ID
  static Map<String, dynamic>? getProductById(int id) {
    try {
      return products.firstWhere((product) => product['id'] == id);
    } catch (e) {
      return null;
    }
  }
}