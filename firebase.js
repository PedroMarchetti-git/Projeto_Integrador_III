// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAiBQP74iC_c06XqsVAIWcg2RQLb0k8s3I",
  authDomain: "pi3-rpg.firebaseapp.com",
  databaseURL: "https://pi3-rpg-default-rtdb.firebaseio.com",
  projectId: "pi3-rpg",
  storageBucket: "pi3-rpg.firebasestorage.app",
  messagingSenderId: "307031613459",
  appId: "1:307031613459:web:eaff304b6a3ab3772a9fe6",
  measurementId: "G-5CLYCEYP1M"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);