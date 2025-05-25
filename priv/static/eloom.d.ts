type Config = {
    endpoint: string;
    writeKey: string;
    batchSize: number;
    flushInterval: number;
};
declare const Eloom: {
    init: ({ endpoint, writeKey }: Config) => void;
    identify: (id: string) => void;
    setUserProperties: (props: any) => void;
    track: (event: string, properties?: {}) => void;
    flush: () => void;
};
export default Eloom;
//# sourceMappingURL=eloom.d.ts.map