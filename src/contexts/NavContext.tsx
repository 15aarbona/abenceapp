import React, { createContext, useContext, useState } from 'react';

interface NavContextType {
  navVisible: boolean;
  hideNav: () => void;
  showNav: () => void;
}

const NavContext = createContext<NavContextType>({
  navVisible: true,
  hideNav: () => {},
  showNav: () => {},
});

export function NavProvider({ children }: { children: React.ReactNode }) {
  const [navVisible, setNavVisible] = useState(true);

  return (
    <NavContext.Provider value={{ navVisible, hideNav: () => setNavVisible(false), showNav: () => setNavVisible(true) }}>
      {children}
    </NavContext.Provider>
  );
}

export const useNav = () => useContext(NavContext);
