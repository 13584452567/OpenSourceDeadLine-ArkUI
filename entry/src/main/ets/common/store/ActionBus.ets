// Central action bus to avoid passing function via @Prop and avoid globalThis usage.
// Components can import openLinkAction / toggleFavoriteAction to invoke actions.
// Index component registers concrete handlers at runtime.

export interface ActionHandlers {
  toggleFavorite: (id: string) => void;
  openLink: (url: string) => void;
}

let toggleFavoriteHandler: ((id: string) => void) | undefined;
let openLinkHandler: ((url: string) => void) | undefined;

export function registerActionHandlers(handlers: ActionHandlers): void {
  toggleFavoriteHandler = handlers.toggleFavorite;
  openLinkHandler = handlers.openLink;
}

export function toggleFavoriteAction(id: string): void {
  if (toggleFavoriteHandler) {
    toggleFavoriteHandler(id);
  } else {
    console.warn('toggleFavoriteAction called before handler registration');
  }
}

export function openLinkAction(url: string): void {
  if (openLinkHandler) {
    openLinkHandler(url);
  } else {
    console.warn('openLinkAction called before handler registration');
  }
}
