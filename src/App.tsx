import { useState } from 'react';
import { ThemeProvider } from './contexts/ThemeContext';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { NavProvider } from './contexts/NavContext';
import { LoginPage } from './pages/LoginPage';
import { HomePage } from './pages/HomePage';
import { VotesPage } from './pages/VotesPage';
import { EventsPage } from './pages/EventsPage';
import { OrdersPage } from './pages/OrdersPage';
import { ProfilePage } from './pages/ProfilePage';
import { Layout } from './components/Layout';

function AppContent() {
  const { user, loading } = useAuth();
  const [currentPage, setCurrentPage] = useState('home');
  console.log('🧐 AppContent - Loading:', loading, 'User:', user);
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-dark-bg">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-fila-red border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-400 text-sm">Carregant...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <LoginPage />;
  }

  const renderPage = () => {
    switch (currentPage) {
      case 'home':
        return <HomePage onNavigate={setCurrentPage} />;
      case 'votes':
        return <VotesPage />;
      case 'events':
        return <EventsPage />;
      case 'orders':
        return <OrdersPage />;
      case 'profile':
        return <ProfilePage />;
      default:
        return <HomePage onNavigate={setCurrentPage} />;
    }
  };

  return (
    <Layout currentPage={currentPage} onNavigate={setCurrentPage}>
      {renderPage()}
    </Layout>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <NavProvider>
          <AppContent />
        </NavProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}
