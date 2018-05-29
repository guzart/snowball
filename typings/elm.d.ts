declare module "*.elm" {
  interface InputPort {
    send: (value: any) => void;
  }

  interface OutputPort {
    subscribe: (callback: Function) => void;
    unsubscribe: (callback: Function) => void;
  }

  // TODO: actually it's a union type not an intersection type
  type ElmPort = InputPort & OutputPort;

  interface ElmApp {
    ports: { [key: string]: ElmPort };
  }

  export namespace Main {
    export function fullscreen(flags: any): ElmApp;
  }
}
